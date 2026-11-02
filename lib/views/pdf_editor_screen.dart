import 'package:flutter/material.dart';
import '../models/library_item.dart';
import 'widgets/pdf_reader_canvas.dart';

enum PdfEditorMode { annotate, edit, organize, fillSign }

class PdfEditorScreen extends StatefulWidget {
  const PdfEditorScreen({
    super.key,
    required this.item,
    required this.mode,
    required this.toolbarBuilder,
    required this.onModeSelected,
    required this.onMore,
  });

  final LibraryItem item;
  final PdfEditorMode mode;
  final Widget Function(int pageCount) toolbarBuilder;
  final ValueChanged<PdfEditorMode> onModeSelected;
  final VoidCallback onMore;

  @override
  State<PdfEditorScreen> createState() => _PdfEditorScreenState();
}

class _PdfEditorScreenState extends State<PdfEditorScreen> {
  int _pageCount = 0;

  String get _title => switch (widget.mode) {
        PdfEditorMode.annotate => 'Annotate',
        PdfEditorMode.edit => 'Edit',
        PdfEditorMode.organize => 'Organize Pages',
        PdfEditorMode.fillSign => 'Fill & Sign',
      };

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: Column(
                  children: [
                    widget.toolbarBuilder(_pageCount),
                    Expanded(
                      child: PdfReaderCanvas(
                        filePath: widget.item.path,
                        showControls: false,
                        onPageCount: (count) => setState(() => _pageCount = count),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _header() => SizedBox(
        height: 58,
        child: Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Color(0xFF2F80ED),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
            PopupMenuButton<PdfEditorMode>(
              initialValue: widget.mode,
              onSelected: widget.onModeSelected,
              itemBuilder: (_) => const [
                PopupMenuItem(value: PdfEditorMode.annotate, child: Text('Annotate')),
                PopupMenuItem(value: PdfEditorMode.edit, child: Text('Edit')),
                PopupMenuItem(value: PdfEditorMode.organize, child: Text('Organize Pages')),
                PopupMenuItem(value: PdfEditorMode.fillSign, child: Text('Fill & Sign')),
              ],
              child: Container(
                height: 44,
                constraints: const BoxConstraints(minWidth: 165),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 9),
                    const Icon(Icons.unfold_more_rounded),
                  ],
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: widget.onMore,
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          ],
        ),
      );
}
