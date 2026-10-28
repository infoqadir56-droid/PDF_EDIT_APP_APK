import 'package:flutter/material.dart';

class PdfNavigationChrome extends StatelessWidget {
  const PdfNavigationChrome({super.key, required this.title, required this.selected, required this.onTabSelected, this.actionLabel, this.onAction});
  final String title;
  final int selected;
  final ValueChanged<int> onTabSelected;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Column(children: [
    SizedBox(height: 57, child: Row(children: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Color(0xFF2F80ED), fontSize: 16))),
      Expanded(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
      SizedBox(width: 64, child: actionLabel == null ? null : TextButton(onPressed: onAction, child: Text(actionLabel!, style: const TextStyle(color: Color(0xFF2F80ED), fontSize: 16)))),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 9), child: Container(height: 42, decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(12)), child: Row(children: [
      _tab(0, Icons.format_list_bulleted_rounded, 'Contents'),
      _tab(1, Icons.bookmark_border_rounded, 'Bookmarks'),
      _tab(2, Icons.text_fields_rounded, 'Annotations'),
    ]))),
    const Divider(height: 1),
  ]);

  Widget _tab(int index, IconData icon, String label) => Expanded(child: Padding(padding: const EdgeInsets.all(3), child: Material(color: selected == index ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10), child: InkWell(onTap: () => onTabSelected(index), borderRadius: BorderRadius.circular(10), child: Tooltip(message: label, child: Center(child: Icon(icon, color: const Color(0xFF707070), size: 24)))))));
}
