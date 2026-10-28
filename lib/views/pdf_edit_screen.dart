import 'package:flutter/material.dart';
import '../models/library_item.dart';
import 'pdf_editor_screen.dart';

class PdfEditScreen extends StatefulWidget {
  const PdfEditScreen({super.key, required this.item, required this.onModeSelected});
  final LibraryItem item;
  final ValueChanged<PdfEditorMode> onModeSelected;
  @override
  State<PdfEditScreen> createState() => _PdfEditScreenState();
}

class _PdfEditScreenState extends State<PdfEditScreen> {
  bool _imageTab = false;

  @override
  Widget build(BuildContext context) => PdfEditorScreen(
        item: widget.item,
        mode: PdfEditorMode.edit,
        onModeSelected: widget.onModeSelected,
        toolbarBuilder: (_) => _toolbar(context),
      );

  Widget _toolbar(BuildContext context) => Column(children: [
        Container(
          height: 42,
          color: const Color(0xFFF5F5F5),
          child: Row(children: [
            _tab('Text', !_imageTab, () => setState(() => _imageTab = false)),
            _tab('Image', _imageTab, () => setState(() => _imageTab = true)),
          ]),
        ),
        SizedBox(
          height: 46,
          child: InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_imageTab ? 'Choose an image to add.' : 'Text placement needs a PDF editing engine.')),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(_imageTab ? Icons.image_outlined : Icons.text_fields_rounded, color: const Color(0xFF2F80ED)),
              const SizedBox(width: 9),
              Text(_imageTab ? 'Add Image' : 'Add Text'),
            ]),
          ),
        ),
      ]);

  Widget _tab(String label, bool selected, VoidCallback action) => Expanded(
        child: InkWell(
          onTap: action,
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 8),
            Container(height: 2, width: 44, color: selected ? Colors.redAccent : Colors.transparent),
          ]),
        ),
      );
}
