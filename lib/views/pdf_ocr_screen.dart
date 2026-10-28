import 'package:flutter/material.dart';
import '../controllers/pdf_actions_controller.dart';

class PdfOcrScreen extends StatefulWidget {
  const PdfOcrScreen({super.key, required this.filePath});
  final String filePath;
  @override
  State<PdfOcrScreen> createState() => _PdfOcrScreenState();
}

class _PdfOcrScreenState extends State<PdfOcrScreen> {
  OcrLanguage language = OcrLanguage.auto;
  bool running = false;
  String? text;
  double progress = 0;
  String? savedPath;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('OCR')),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DropdownButtonFormField<OcrLanguage>(initialValue: language, decoration: const InputDecoration(labelText: 'Recognition language', border: OutlineInputBorder()), items: OcrLanguage.values.map((v) => DropdownMenuItem(value: v, child: Text(v.label))).toList(), onChanged: running ? null : (v) => setState(() => language = v!)),
      const SizedBox(height: 14),
      FilledButton.icon(onPressed: running ? null : _run, icon: const Icon(Icons.document_scanner_outlined), label: Text(running ? 'Recognizing ${(progress * 100).round()}%' : 'Apply OCR')),
      if (running) LinearProgressIndicator(value: progress),
      if (savedPath != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Saved: $savedPath', style: const TextStyle(color: Colors.black54))),
      const SizedBox(height: 14),
      Expanded(child: SingleChildScrollView(child: SelectableText(text ?? 'Recognized text will appear here and be saved as a .txt file.', style: TextStyle(color: text == null ? Colors.black45 : Colors.black87)))),
    ])),
  );
  Future<void> _run() async {
    setState(() { running = true; progress = 0; text = null; });
    try {
      final result = await PdfActionsController.recognizeText(widget.filePath, language, (v) { if (mounted) setState(() => progress = v); });
      if (mounted) setState(() { text = result.text; savedPath = result.path; });
    } catch (e) { if (mounted) setState(() => text = 'OCR failed: $e'); }
    finally { if (mounted) setState(() => running = false); }
  }
}
