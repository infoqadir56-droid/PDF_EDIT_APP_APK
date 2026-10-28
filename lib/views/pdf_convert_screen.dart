import 'package:flutter/material.dart';

enum PdfExportFormat { doc, docx, xls, xlsx, pptx, jpg, png, rtf }

class PdfConvertScreen extends StatefulWidget {
  const PdfConvertScreen({super.key, required this.onConvert});
  final Future<String?> Function(PdfExportFormat format) onConvert;
  @override
  State<PdfConvertScreen> createState() => _PdfConvertScreenState();
}

class _PdfConvertScreenState extends State<PdfConvertScreen> {
  PdfExportFormat selected = PdfExportFormat.docx;
  bool working = false;
  String? result;
  static const formats = <(PdfExportFormat, String)>[
    (PdfExportFormat.doc, 'Microsoft Word (*.doc)'), (PdfExportFormat.docx, 'Microsoft Word (*.docx)'),
    (PdfExportFormat.xls, 'Microsoft Excel (*.xls)'), (PdfExportFormat.xlsx, 'Microsoft Excel (*.xlsx)'),
    (PdfExportFormat.pptx, 'Microsoft PowerPoint (*.pptx)'), (PdfExportFormat.jpg, 'JPG (*.jpeg)'),
    (PdfExportFormat.png, 'PNG (*.png)'), (PdfExportFormat.rtf, 'Rich Text Format (*.rtf)'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Convert PDF')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Convert to…', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      RadioGroup<PdfExportFormat>(
        groupValue: selected,
        onChanged: (v) {
          if (!working && v != null) {
            setState(() => selected = v);
          }
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: formats.map((entry) => RadioListTile<PdfExportFormat>(
              value: entry.$1,
              title: Text(entry.$2),
            )).toList(),
          ),
        ),
      ),
      const SizedBox(height: 20),
      if (result != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(result!, textAlign: TextAlign.center)),
      SizedBox(height: 52, child: FilledButton(onPressed: working ? null : _convert, child: working ? const CircularProgressIndicator() : const Text('Convert'))),
    ]),
  );
  Future<void> _convert() async {
    setState(() { working = true; result = null; });
    try { final message = await widget.onConvert(selected); if (mounted) setState(() => result = message ?? 'Conversion cancelled.'); }
    catch (error) { if (mounted) setState(() => result = 'Could not convert this PDF: $error'); }
    finally { if (mounted) setState(() => working = false); }
  }
}
