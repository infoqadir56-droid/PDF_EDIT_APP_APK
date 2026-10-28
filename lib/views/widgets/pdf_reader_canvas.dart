import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../models/pdf_view_settings.dart';

class PdfReaderCanvas extends StatefulWidget {
  const PdfReaderCanvas({super.key, required this.filePath, this.onPageChanged, this.onPageCount, this.onControllerReady, this.showControls = true, this.scrollDirection = Axis.vertical, this.pageBackground = Colors.white, this.brightness = 0, this.paperTheme = PdfPaperTheme.original});
  final String filePath;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onPageCount;
  final ValueChanged<PdfControllerPinch>? onControllerReady;
  final bool showControls;
  final Axis scrollDirection;
  final Color pageBackground;
  final double brightness;
  final PdfPaperTheme paperTheme;
  @override
  State<PdfReaderCanvas> createState() => _PdfReaderCanvasState();
}

class _PdfReaderCanvasState extends State<PdfReaderCanvas> {
  late final PdfControllerPinch _controller = PdfControllerPinch(document: PdfDocument.openFile(widget.filePath));
  int _page = 1, _pageCount = 0;
  Object? _error;
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) widget.onControllerReady?.call(_controller); }); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: _error == null ? ColorFiltered(colorFilter: _viewFilter, child: PdfViewPinch(controller: _controller,
      scrollDirection: widget.scrollDirection,
      backgroundDecoration: BoxDecoration(color: widget.pageBackground),
      onPageChanged: (page) { setState(() => _page = page); widget.onPageChanged?.call(page); },
      onDocumentLoaded: (document) { setState(() => _pageCount = document.pagesCount); widget.onPageCount?.call(document.pagesCount); },
      onDocumentError: (error) => setState(() => _error = error),
    )) : Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.picture_as_pdf_rounded, size: 48, color: Color(0xFFD75D57)),
      const SizedBox(height: 12), const Text('Could not display this PDF', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      const SizedBox(height: 6), Text('The file may be damaged or protected.\n$_error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 12)),
    ])))),
    if (widget.showControls && _pageCount > 1) Container(height: 46, color: Colors.white, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(onPressed: _page > 1 ? () => _controller.previousPage(duration: const Duration(milliseconds: 180), curve: Curves.easeOut) : null, icon: const Icon(Icons.chevron_left_rounded)),
      Text('$_page / $_pageCount', style: const TextStyle(fontSize: 13, color: Colors.black54)),
      IconButton(onPressed: _page < _pageCount ? () => _controller.nextPage(duration: const Duration(milliseconds: 180), curve: Curves.easeOut) : null, icon: const Icon(Icons.chevron_right_rounded)),
    ])),
  ]);

  ColorFilter get _viewFilter {
    final b = widget.brightness * 255;
    final matrix = switch (widget.paperTheme) {
      PdfPaperTheme.night => <double>[-1, 0, 0, 0, 255 + b, 0, -1, 0, 0, 255 + b, 0, 0, -1, 0, 255 + b, 0, 0, 0, 1, 0],
      PdfPaperTheme.sepia => <double>[0.393, 0.769, 0.189, 0, b, 0.349, 0.686, 0.168, 0, b, 0.272, 0.534, 0.131, 0, b, 0, 0, 0, 1, 0],
      PdfPaperTheme.green => <double>[0.9, 0.08, 0, 0, b, 0.04, 0.92, 0.04, 0, b, 0, 0.08, 0.9, 0, b, 0, 0, 0, 1, 0],
      _ => <double>[1, 0, 0, 0, b, 0, 1, 0, 0, b, 0, 0, 1, 0, b, 0, 0, 0, 1, 0],
    };
    return ColorFilter.matrix(matrix);
  }
}
