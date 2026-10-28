import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:dart_pptx/dart_pptx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:printing/printing.dart';
import '../views/pdf_convert_screen.dart';

enum OcrLanguage { auto, chinese, japanese, korean }
extension OcrLanguageLabel on OcrLanguage { String get label => switch (this) { OcrLanguage.auto => 'Auto (Latin)', OcrLanguage.chinese => '中文', OcrLanguage.japanese => '日本語', OcrLanguage.korean => '한국어' }; }
class OcrResult { const OcrResult(this.text, this.path); final String text, path; }

class PdfActionsController {
  static Future<String?> share(String path, String name) async {
    await Printing.sharePdf(bytes: await File(path).readAsBytes(), filename: name);
    return 'Share sheet opened.';
  }

  static Future<String?> print(String path) async {
    await Printing.layoutPdf(onLayout: (_) async => File(path).readAsBytes());
    return 'Print dialog opened.';
  }

  static Future<String?> saveAs(String path, String name) async {
    final bytes = await File(path).readAsBytes();
    final destination = await FilePicker.platform.saveFile(fileName: name, bytes: bytes, dialogTitle: 'Save PDF as');
    return destination == null ? null : 'Saved PDF to $destination';
  }

  static Future<OcrResult> recognizeText(String path, OcrLanguage language, ValueChanged<double> onProgress) async {
    final script = switch (language) { OcrLanguage.auto => TextRecognitionScript.latin, OcrLanguage.chinese => TextRecognitionScript.chinese, OcrLanguage.japanese => TextRecognitionScript.japanese, OcrLanguage.korean => TextRecognitionScript.korean };
    final recognizer = TextRecognizer(script: script);
    final document = await PdfDocument.openFile(path);
    final output = StringBuffer();
    try {
      for (var index = 1; index <= document.pagesCount; index++) {
        final page = await document.getPage(index);
        final rendered = await page.render(width: page.width * 2, height: page.height * 2, format: PdfPageImageFormat.png);
        await page.close();
        if (rendered != null) {
          final temp = File('${Directory.systemTemp.path}${Platform.pathSeparator}pdf-ocr-${DateTime.now().microsecondsSinceEpoch}.png');
          await temp.writeAsBytes(rendered.bytes, flush: true);
          final recognized = await recognizer.processImage(InputImage.fromFilePath(temp.path));
          output.writeln('--- Page $index ---\n${recognized.text}\n');
          try { await temp.delete(); } catch (_) {}
        }
        onProgress(index / document.pagesCount);
      }
    } finally { await recognizer.close(); await document.close(); }
    final docs = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${docs.path}${Platform.pathSeparator}paper_library${Platform.pathSeparator}exports');
    await exportDir.create(recursive: true);
    final file = File('${exportDir.path}${Platform.pathSeparator}${_base(path)}-ocr.txt');
    await file.writeAsString(output.toString(), flush: true);
    return OcrResult(output.toString(), file.path);
  }

  static Future<String?> convert(String path, PdfExportFormat format) async {
    final doc = await PdfDocument.openFile(path);
    try {
      if (format == PdfExportFormat.jpg || format == PdfExportFormat.png) {
        final extension = format == PdfExportFormat.jpg ? 'jpg' : 'png';
        final dir = await _exportDir();
        for (var i = 1; i <= doc.pagesCount; i++) {
          final page = await doc.getPage(i);
          final image = await page.render(width: page.width * 2, height: page.height * 2, format: format == PdfExportFormat.jpg ? PdfPageImageFormat.jpeg : PdfPageImageFormat.png);
          await page.close();
          if (image != null) await File('${dir.path}${Platform.pathSeparator}${_base(path)}-page-$i.$extension').writeAsBytes(image.bytes, flush: true);
        }
        return 'Saved $extension page images in ${dir.path}';
      }
      if (format == PdfExportFormat.xlsx) {
        final recognized = await recognizeText(path, OcrLanguage.auto, (_) {});
        return _convertXlsx(path, recognized.text);
      }
      if (format == PdfExportFormat.rtf) {
        final recognized = await recognizeText(path, OcrLanguage.auto, (_) {});
        return _convertRtf(path, recognized.text);
      }
      if (format == PdfExportFormat.docx) {
        final recognized = await recognizeText(path, OcrLanguage.auto, (_) {});
        return _convertDocx(path, recognized.text);
      }
      if (format == PdfExportFormat.pptx) {
        final recognized = await recognizeText(path, OcrLanguage.auto, (_) {});
        return _convertPptx(path, recognized.text);
      }
      final description = switch (format) {
        PdfExportFormat.doc => 'Legacy .doc export is unavailable; choose .docx or .rtf.',
        PdfExportFormat.docx => 'DOCX conversion could not be completed.',
        PdfExportFormat.xls => 'Legacy .xls writing is not supported; choose .xlsx.',
        PdfExportFormat.pptx => 'Could not create the PowerPoint file.',
        _ => 'This output format is not supported.',
      };
      return description;
    } finally { await doc.close(); }
  }

  static Future<String?> _convertRtf(String path, String text) async {
    final output = StringBuffer(r'{\rtf1\ansi\deff0 ');
    for (final line in text.split('\n')) { output.write('${_escape(line)}\\par '); }
    output.write('}');
    final dir = await _exportDir();
    final file = File('${dir.path}${Platform.pathSeparator}${_base(path)}.rtf');
    await file.writeAsString(output.toString(), flush: true);
    return 'Saved RTF document to ${file.path}';
  }

  static Future<String?> _convertDocx(String path, String text) async {
    final archive = Archive();
    void add(String name, String content) { final bytes = Uint8List.fromList(utf8.encode(content)); archive.addFile(ArchiveFile(name, bytes.length, bytes)); }
    add('[Content_Types].xml', '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>''');
    add('_rels/.rels', '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>''');
    final paragraphs = text.split('\n').map((line) => '<w:p><w:r><w:t xml:space="preserve">${_xml(line)}</w:t></w:r></w:p>').join();
    add('word/document.xml', '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>$paragraphs<w:sectPr/></w:body></w:document>''');
    final bytes = ZipEncoder().encode(archive);
    final dir = await _exportDir();
    final file = File('${dir.path}${Platform.pathSeparator}${_base(path)}.docx');
    await file.writeAsBytes(bytes!, flush: true);
    return 'Saved OCR text as DOCX to ${file.path}';
  }

  static Future<String?> _convertXlsx(String path, String text) async {
    final excel = Excel.createExcel();
    final sheet = excel['PDF'];
    sheet.appendRow([TextCellValue('Page'), TextCellValue('Recognized text')]);
    var pageNumber = 0;
    for (final page in text.split(RegExp(r'--- Page \d+ ---'))) {
      if (page.trim().isEmpty) continue;
      pageNumber++;
      sheet.appendRow([IntCellValue(pageNumber), TextCellValue(page.trim())]);
    }
    final bytes = excel.encode();
    if (bytes == null) throw StateError('Could not create the Excel workbook.');
    final dir = await _exportDir();
    final file = File('${dir.path}${Platform.pathSeparator}${_base(path)}.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return 'Saved page index workbook to ${file.path}';
  }

  static Future<String?> _convertPptx(String path, String text) async {
    final presentation = PowerPoint()..title = _base(path)..author = 'PDF App';
    presentation.addTitleSlide(title: _base(path).toTextValue(), author: 'Converted from PDF'.toTextValue());
    final pages = text.split(RegExp(r'--- Page \d+ ---')).where((p) => p.trim().isNotEmpty).toList();
    for (var i = 0; i < pages.length; i++) {
      final lines = pages[i].split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).take(20).toList();
      if (lines.isEmpty) lines.add('(No text recognized on this page)');
      presentation.addTitleAndBulletsSlide(title: 'Page ${i + 1}'.toTextValue(), bullets: lines.map((line) => line.toTextValue()).toList());
    }
    final bytes = await presentation.save();
    if (bytes == null) throw StateError('Could not create the PowerPoint presentation.');
    final dir = await _exportDir();
    final file = File('${dir.path}${Platform.pathSeparator}${_base(path)}.pptx');
    await file.writeAsBytes(bytes, flush: true);
    return 'Saved OCR text as PowerPoint to ${file.path}';
  }

  static Future<Directory> _exportDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}paper_library${Platform.pathSeparator}exports');
    await dir.create(recursive: true);
    return dir;
  }
  static String _base(String path) { final name = path.split(RegExp(r'[/\\]')).last; final dot = name.lastIndexOf('.'); return dot > 0 ? name.substring(0, dot) : name; }
  static String _escape(String value) => value.replaceAll('\\', r'\\').replaceAll('{', r'\{').replaceAll('}', r'\}');
  static String _xml(String value) => value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}
