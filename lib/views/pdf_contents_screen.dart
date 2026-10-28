import 'package:flutter/material.dart';
import 'widgets/pdf_navigation_chrome.dart';

class PdfContentsScreen extends StatelessWidget {
  const PdfContentsScreen({super.key, required this.onTabSelected});
  final ValueChanged<int> onTabSelected;
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFFAFAFA), body: SafeArea(child: Column(children: [
    PdfNavigationChrome(title: 'Table of Contents', selected: 0, onTabSelected: onTabSelected),
    const Expanded(child: Center(child: Text('No table of contents in this PDF', style: TextStyle(color: Colors.black54, fontSize: 15)))),
  ])));
}
