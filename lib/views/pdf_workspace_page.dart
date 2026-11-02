import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../controllers/pdf_actions_controller.dart';
import '../models/library_item.dart';
import '../models/pdf_view_settings.dart';
import 'pdf_ai_screen.dart';
import 'pdf_annotate_screen.dart';
import 'pdf_annotations_screen.dart';
import 'pdf_bookmarks_screen.dart';
import 'pdf_contents_screen.dart';
import 'pdf_edit_screen.dart';
import 'pdf_editor_screen.dart';
import 'pdf_fill_sign_screen.dart';
import 'pdf_more_screen.dart';
import 'pdf_convert_screen.dart';
import 'pdf_goto_page_screen.dart';
import 'pdf_ocr_screen.dart';
import 'pdf_view_settings_screen.dart';
import 'pdf_organize_pages_screen.dart';
import 'pdf_search_screen.dart';
import 'widgets/pdf_reader_canvas.dart';

const _blue = Color(0xFF2F80ED);

class PdfWorkspacePage extends StatefulWidget {
  const PdfWorkspacePage({super.key, required this.item});
  final LibraryItem item;
  @override
  State<PdfWorkspacePage> createState() => _PdfWorkspacePageState();
}

class _PdfWorkspacePageState extends State<PdfWorkspacePage> {
  int _page = 1, _pageCount = 0;
  PdfControllerPinch? _pdfController;
  PdfViewSettings _viewSettings = const PdfViewSettings();

  @override
  void initState() { super.initState(); _loadViewSettings(); }

  Future<void> _loadViewSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('pdf.view.settings.v1');
    if (!mounted || raw == null) return;
    try { setState(() => _viewSettings = PdfViewSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>)); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFFAFAFA), body: SafeArea(child: Column(children: [
    _header(),
    Expanded(child: PdfReaderCanvas(filePath: widget.item.path, onControllerReady: (c) => _pdfController = c, scrollDirection: _viewSettings.horizontal ? Axis.horizontal : Axis.vertical, pageBackground: _viewSettings.background, brightness: _viewSettings.brightness, paperTheme: _viewSettings.theme, onPageChanged: (p) => setState(() => _page = p), onPageCount: (n) => setState(() => _pageCount = n))),
  ])));

  Widget _header() => Container(height: 58, decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE6E6E6)))), child: Row(children: [
    IconButton(tooltip: 'Back', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21)),
    const Spacer(),
    _editButton(),
    _headerIcon(Icons.auto_awesome_outlined, 'AI', () => PdfAiScreen.show(context, widget.item)),
    _headerIcon(Icons.search_rounded, 'Search', () => _push(PdfSearchScreen(fileName: widget.item.name))),
    _headerIcon(Icons.bookmark_border_rounded, 'Contents, bookmarks, annotations', () => _push(PdfContentsScreen(onTabSelected: _switchNavigation))),
    _headerIcon(Icons.more_horiz_rounded, 'More', () => _showMore()),
  ]));

  Widget _editButton() => Padding(padding: const EdgeInsets.only(left: 6), child: TextButton(onPressed: () => _openMode(PdfEditorMode.annotate), style: TextButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, shape: const StadiumBorder(), minimumSize: const Size(68, 38), padding: const EdgeInsets.symmetric(horizontal: 16)), child: const Text('Edit', style: TextStyle(fontSize: 15))));
  Widget _headerIcon(IconData icon, String tooltip, VoidCallback action) => IconButton(tooltip: tooltip, onPressed: action, icon: Icon(icon, size: 24, color: const Color(0xFF777777)));

  void _push(Widget screen) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  Future<void> _showMore() => PdfMoreScreen.show(context, widget.item, _page,
    onViewSettings: _openViewSettings, onGoToPage: _goToPage,
    onConvert: _convert, onShare: _share, onPrint: _print, onSaveAs: _saveAs,
    onOcr: () async => _push(PdfOcrScreen(filePath: widget.item.path)));

  Future<void> _openViewSettings() async {
    final value = await Navigator.of(context).push<PdfViewSettings>(MaterialPageRoute(builder: (_) => PdfViewSettingsScreen(initial: _viewSettings)));
    if (value == null || !mounted) return;
    setState(() => _viewSettings = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pdf.view.settings.v1', jsonEncode(value.toJson()));
  }

  Future<void> _goToPage() async {
    final page = await PdfGoToPageScreen.show(context, currentPage: _page, pageCount: _pageCount);
    if (page != null) await _pdfController?.animateToPage(pageNumber: page, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }
  Future<void> _convert() async => _push(PdfConvertScreen(onConvert: (format) => PdfActionsController.convert(widget.item.path, format)));
  Future<void> _share() => _runAction(() => PdfActionsController.share(widget.item.path, widget.item.name));
  Future<void> _print() => _runAction(() => PdfActionsController.print(widget.item.path));
  Future<void> _saveAs() => _runAction(() => PdfActionsController.saveAs(widget.item.path, widget.item.name));
  Future<void> _runAction(Future<String?> Function() action) async {
    try { _notify(await action()); }
    catch (error) { _notify('Action failed: $error'); }
  }
  void _notify(String? message) { if (message != null && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating)); }
  void _openMode(PdfEditorMode mode) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _editorPage(mode)));
  void _switchMode(PdfEditorMode mode) => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => _editorPage(mode)));

  void _switchNavigation(int tab) => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => _navigationPage(tab)));

  Widget _navigationPage(int tab) => switch (tab) {
    0 => PdfContentsScreen(onTabSelected: _switchNavigation),
    1 => PdfBookmarksScreen(currentPage: _page, onTabSelected: _switchNavigation),
    _ => PdfAnnotationsScreen(onTabSelected: _switchNavigation),
  };

  Widget _editorPage(PdfEditorMode mode) => switch (mode) {
    PdfEditorMode.annotate => PdfAnnotateScreen(item: widget.item, onModeSelected: _switchMode, onMore: () => _showMore()),
    PdfEditorMode.edit => PdfEditScreen(item: widget.item, onModeSelected: _switchMode, onMore: () => _showMore()),
    PdfEditorMode.organize => PdfOrganizePagesScreen(item: widget.item, onModeSelected: _switchMode, onMore: () => _showMore()),
    PdfEditorMode.fillSign => PdfFillSignScreen(item: widget.item, onModeSelected: _switchMode, onMore: () => _showMore()),
  };

}
