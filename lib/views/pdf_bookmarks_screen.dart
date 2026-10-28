import 'package:flutter/material.dart';
import 'widgets/pdf_navigation_chrome.dart';

class PdfBookmarksScreen extends StatefulWidget {
  const PdfBookmarksScreen({super.key, required this.onTabSelected, this.currentPage = 1});
  final ValueChanged<int> onTabSelected;
  final int currentPage;
  @override
  State<PdfBookmarksScreen> createState() => _PdfBookmarksScreenState();
}

class _PdfBookmarksScreenState extends State<PdfBookmarksScreen> {
  bool _editing = false, _added = false;
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFFAFAFA), body: SafeArea(child: Column(children: [
    PdfNavigationChrome(title: 'Bookmarks', selected: 1, onTabSelected: widget.onTabSelected, actionLabel: _added ? (_editing ? 'Done' : 'Edit') : null, onAction: () => setState(() => _editing = !_editing)),
    Expanded(child: _added ? ListTile(leading: const Icon(Icons.bookmark_rounded, color: Color(0xFF2F80ED)), title: Text('Page ${widget.currentPage}'), trailing: _editing ? IconButton(onPressed: () => setState(() => _added = false), icon: const Icon(Icons.remove_circle_outline)) : null) : const SizedBox()),
    SafeArea(top: false, child: SizedBox(height: 58, child: TextButton.icon(onPressed: () => setState(() => _added = true), icon: const Icon(Icons.add_rounded), label: const Text('Add a Bookmark', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))))),
  ])));
}
