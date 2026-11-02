import 'package:flutter/material.dart';
import '../models/library_item.dart';
import 'pdf_editor_screen.dart';

class PdfOrganizePagesScreen extends StatelessWidget {
  const PdfOrganizePagesScreen({super.key, required this.item, required this.onModeSelected, required this.onMore});
  final LibraryItem item;
  final ValueChanged<PdfEditorMode> onModeSelected;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => PdfEditorScreen(
        item: item,
        mode: PdfEditorMode.organize,
        onModeSelected: onModeSelected,
        onMore: onMore,
        toolbarBuilder: (pageCount) => _OrganizeToolbar(pageCount: pageCount),
      );
}

class _OrganizeToolbar extends StatefulWidget {
  const _OrganizeToolbar({required this.pageCount});
  final int pageCount;
  @override
  State<_OrganizeToolbar> createState() => _OrganizeToolbarState();
}

class _OrganizeToolbarState extends State<_OrganizeToolbar> {
  final Set<int> _selectedPages = {};

  @override
  Widget build(BuildContext context) => Column(children: [
        _actionStrip(context),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          color: const Color(0xFFE7F1FC),
          child: Row(children: [
            InkWell(
              onTap: _toggleAll,
              child: Row(children: [
                Icon(_allSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: const Color(0xFF2F80ED)),
                const SizedBox(width: 8),
                const Text('All'),
              ]),
            ),
            const Spacer(),
            Text('${_selectedPages.isEmpty ? 1 : _selectedPages.length} Selected'),
            const Spacer(),
          ]),
        ),
        SizedBox(
          height: 112,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: widget.pageCount,
            itemBuilder: (context, index) => _pageTile(index + 1),
          ),
        ),
      ]);

  bool get _allSelected => widget.pageCount > 0 && _selectedPages.length == widget.pageCount;

  Widget _actionStrip(BuildContext context) => Container(
        height: 54,
        color: const Color(0xFFF6F6F6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _action(context, Icons.note_add_outlined, 'Insert page'),
            _action(context, Icons.copy_outlined, 'Duplicate'),
            _action(context, Icons.delete_outline_rounded, 'Delete'),
            _action(context, Icons.rotate_right_rounded, 'Rotate'),
            IconButton(onPressed: () => _message(context, 'Nothing to undo yet.'), icon: const Icon(Icons.undo_rounded, color: Colors.black38)),
          ]),
        ),
      );

  Widget _action(BuildContext context, IconData icon, String label) => IconButton(
        tooltip: label,
        onPressed: () => _message(context, '$label needs a PDF editing engine.'),
        icon: Icon(icon, size: 23, color: Colors.black54),
      );

  Widget _pageTile(int page) {
    final selected = _selectedPages.contains(page);
    return InkWell(
      onTap: () => setState(() => selected ? _selectedPages.remove(page) : _selectedPages.add(page)),
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: selected ? const Color(0xFF2F80ED) : const Color(0xFFDDDDDD), width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(children: [
          Center(child: Text('$page', style: const TextStyle(color: Colors.black45))),
          Positioned(top: 3, left: 3, child: Icon(selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 17, color: selected ? const Color(0xFF2F80ED) : Colors.black38)),
        ]),
      ),
    );
  }

  void _toggleAll() => setState(() {
        if (_allSelected) {
          _selectedPages.clear();
        } else {
          _selectedPages.addAll(List.generate(widget.pageCount, (index) => index + 1));
        }
      });

  void _message(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
}
