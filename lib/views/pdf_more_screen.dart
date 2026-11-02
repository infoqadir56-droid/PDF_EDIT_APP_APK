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
    SafeArea(child: Align(alignment: Alignment.topCenter, child: Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height - 100),
      width: MediaQuery.sizeOf(context).width - 52,
      margin: const EdgeInsets.only(top: 66),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 22, offset: Offset(0, 8))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF202124), decoration: TextDecoration.none)),
            const SizedBox(height: 4),
            Text('Page $currentPage', style: const TextStyle(color: Color(0xFF70757A), fontSize: 14, decoration: TextDecoration.none)),
          ])),
          IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
        ]),
        const SizedBox(height: 10),
        Flexible(child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < entries.length; i++) _action(context, i),
        ]))),
      ]),
    ))),
  ]);

  Widget _action(BuildContext context, int index) {
    final (icon, title) = entries[index];
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () { Navigator.pop(context); actions[index](); },
      child: Container(
        height: 54,
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEAECEF)))),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF202124), fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none))),
          Icon(icon, color: const Color(0xFF646A73), size: 22),
        ]),
      ),
    );
  }
}
