import 'package:flutter/material.dart';
import '../models/library_item.dart';
import 'pdf_editor_screen.dart';

class PdfAnnotateScreen extends StatelessWidget {
  const PdfAnnotateScreen({super.key, required this.item, required this.onModeSelected});
  final LibraryItem item;
  final ValueChanged<PdfEditorMode> onModeSelected;

  @override
  Widget build(BuildContext context) => PdfEditorScreen(
        item: item,
        mode: PdfEditorMode.annotate,
        onModeSelected: onModeSelected,
        toolbarBuilder: (_) => const _AnnotateToolbar(),
      );
}

class _AnnotateToolbar extends StatefulWidget {
  const _AnnotateToolbar();
  @override
  State<_AnnotateToolbar> createState() => _AnnotateToolbarState();
}

class _AnnotateToolbarState extends State<_AnnotateToolbar> {
  int _selected = 0;
  static const _tools = [
    (Icons.highlight_rounded, 'Highlight', Color(0xFFFFEA00)),
    (Icons.format_underline_rounded, 'Underline', Color(0xFFB7F1A8)),
    (Icons.format_strikethrough_rounded, 'Strikethrough', Color(0xFFFF9E9E)),
    (Icons.edit_outlined, 'Pen', null),
    (Icons.draw_outlined, 'Pencil', null),
    (Icons.cleaning_services_outlined, 'Eraser', null),
    (Icons.chat_bubble_outline_rounded, 'Comment', null),
    (Icons.text_fields_rounded, 'Add Text', null),
  ];

  @override
  Widget build(BuildContext context) => Container(
        height: 54,
        color: const Color(0xFFF6F6F6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < _tools.length; i++) _tool(context, i),
            IconButton(
              tooltip: 'Undo',
              onPressed: () => _message(context, 'Nothing to undo yet.'),
              icon: const Icon(Icons.undo_rounded, color: Colors.black38),
            ),
          ]),
        ),
      );

  Widget _tool(BuildContext context, int index) {
    final (icon, label, color) = _tools[index];
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () {
          setState(() => _selected = index);
          if (index >= 6) _message(context, '$label needs a PDF editing engine.');
        },
        child: Container(
          width: 45,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _selected == index ? (color ?? Colors.transparent) : Colors.transparent,
            border: _selected == index && color == null
                ? const Border(bottom: BorderSide(color: Color(0xFF2F80ED), width: 2))
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 22, color: Colors.black54),
        ),
      ),
    );
  }

  void _message(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
}
