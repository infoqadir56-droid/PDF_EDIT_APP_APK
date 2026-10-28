import 'package:flutter/material.dart';
import 'widgets/pdf_navigation_chrome.dart';

class PdfAnnotationsScreen extends StatefulWidget {
  const PdfAnnotationsScreen({super.key, required this.onTabSelected});
  final ValueChanged<int> onTabSelected;
  @override
  State<PdfAnnotationsScreen> createState() => _PdfAnnotationsScreenState();
}

class _PdfAnnotationsScreenState extends State<PdfAnnotationsScreen> {
  bool _editing = false;
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFFAFAFA), body: SafeArea(child: Column(children: [
    PdfNavigationChrome(title: 'Annotations', selected: 2, onTabSelected: widget.onTabSelected, actionLabel: 'Edit', onAction: () => setState(() => _editing = !_editing)),
    const Expanded(child: SizedBox()),
    if (_editing) const Padding(padding: EdgeInsets.all(18), child: Text('There are no annotations to edit.', style: TextStyle(color: Colors.black54))),
  ])));
}
