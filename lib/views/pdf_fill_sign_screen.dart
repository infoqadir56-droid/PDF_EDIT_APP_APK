import 'package:flutter/material.dart';
import '../models/library_item.dart';
import 'pdf_editor_screen.dart';

class PdfFillSignScreen extends StatelessWidget {
  const PdfFillSignScreen({super.key, required this.item, required this.onModeSelected, required this.onMore});
  final LibraryItem item;
  final ValueChanged<PdfEditorMode> onModeSelected;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => PdfEditorScreen(
        item: item,
        mode: PdfEditorMode.fillSign,
        onModeSelected: onModeSelected,
        onMore: onMore,
        toolbarBuilder: (_) => const _FillSignToolbar(),
      );
}

class _FillSignToolbar extends StatelessWidget {
  const _FillSignToolbar();

  @override
  Widget build(BuildContext context) => Container(
        height: 54,
        color: const Color(0xFFF6F6F6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _tool(context, Icons.text_fields_rounded, 'Add text'),
            _tool(context, Icons.check_rounded, 'Check mark'),
            _tool(context, Icons.close_rounded, 'Cross mark'),
            _tool(context, Icons.approval_outlined, 'Stamp'),
            _tool(context, Icons.draw_rounded, 'Signature'),
            IconButton(onPressed: () => _message(context, 'Nothing to undo yet.'), icon: const Icon(Icons.undo_rounded, color: Colors.black38)),
          ]),
        ),
      );

  Widget _tool(BuildContext context, IconData icon, String label) => IconButton(
        tooltip: label,
        onPressed: () => _message(context, '$label needs a PDF editing engine.'),
        icon: Icon(icon, size: 23, color: Colors.black54),
      );

  void _message(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
}
