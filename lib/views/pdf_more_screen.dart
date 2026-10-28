import 'package:flutter/material.dart';
import '../models/library_item.dart';

class PdfMoreScreen {
  static Future<void> show(BuildContext context, LibraryItem item, int currentPage, {
    required Future<void> Function() onViewSettings,
    required Future<void> Function() onGoToPage,
    required Future<void> Function() onConvert,
    required Future<void> Function() onShare,
    required Future<void> Function() onPrint,
    required Future<void> Function() onSaveAs,
    required Future<void> Function() onOcr,
  }) => showGeneralDialog<void>(context: context, barrierDismissible: true, barrierLabel: 'Close PDF menu', barrierColor: const Color(0x18000000), pageBuilder: (context, animation, secondaryAnimation) => _PdfMoreMenu(
    item: item, currentPage: currentPage, actions: [onViewSettings, onGoToPage, onConvert, onShare, onPrint, onSaveAs, onOcr],
  ));
}

class _PdfMoreMenu extends StatelessWidget {
  const _PdfMoreMenu({required this.item, required this.currentPage, required this.actions});
  final LibraryItem item;
  final int currentPage;
  final List<Future<void> Function()> actions;
  static const entries = <(IconData, String)>[
    (Icons.visibility_outlined, 'View Settings'), (Icons.input_rounded, 'Go to Page'),
    (Icons.picture_as_pdf_outlined, 'Convert'), (Icons.share_outlined, 'Share'),
    (Icons.print_outlined, 'Print'), (Icons.save_alt_rounded, 'Save as'),
    (Icons.document_scanner_outlined, 'OCR'),
  ];
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: GestureDetector(onTap: () => Navigator.pop(context))),
    SafeArea(child: Align(alignment: Alignment.topRight, child: Container(
      width: MediaQuery.sizeOf(context).width - 30,
      margin: const EdgeInsets.only(top: 56, right: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFDDDDDD)), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 4))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(alignment: Alignment.centerLeft, child: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
        const SizedBox(height: 8), Align(alignment: Alignment.centerLeft, child: Text('Page $currentPage', style: const TextStyle(color: Colors.black54))),
        const SizedBox(height: 8),
        for (var i = 0; i < entries.length; i++) _action(context, i),
      ]),
    ))),
  ]);

  Widget _action(BuildContext context, int index) {
    final (icon, title) = entries[index];
    return InkWell(onTap: () { Navigator.pop(context); actions[index](); }, child: Container(height: 53, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))), Icon(icon, color: const Color(0xFF646A73), size: 22)])));
  }
}
