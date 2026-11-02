import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/library_controller.dart';
import '../controllers/pdf_actions_controller.dart';
import '../models/library_item.dart';
import 'folder_contents_screen.dart';
import 'pdf_workspace_page.dart';
import 'settings_feedback_screen.dart';
import 'settings_language_screen.dart';

const _blue = Color(0xFF2F80ED), _ink = Color(0xFF171717), _muted = Color(0xFF9A9A9A);

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, required this.controller, required this.language, required this.themeMode, required this.onLanguageChanged, required this.onThemeChanged});
  final LibraryController controller;
  final String language;
  final ThemeMode themeMode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _tab = 0;
  bool _favorites = false, _grid = true, _ascending = false;
  String _sortField = 'date';
  String? _kindFilter;
  String _query = '';
  final _search = TextEditingController();
  final _sortButtonKey = GlobalKey();
  LibraryController get c => widget.controller;
  @override
  void initState() { super.initState(); c.addListener(_changed); }
  @override
  void dispose() { c.removeListener(_changed); _search.dispose(); super.dispose(); }
  void _changed() { if (mounted) setState(() {}); }
  void _toast(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(bottom: false, child: _tab == 2 ? _settings() : _library()),
    floatingActionButton: _tab == 0 ? FloatingActionButton(onPressed: _addMenu,
      backgroundColor: _blue, foregroundColor: Colors.white, elevation: 2,
      shape: const CircleBorder(), child: const Icon(Icons.add_rounded, size: 34)) : null,
    bottomNavigationBar: NavigationBar(height: 72, selectedIndex: _tab,
      onDestinationSelected: (v) => setState(() { _tab = v; if (v == 1) { _favorites = false; _kindFilter = null; } }),
      backgroundColor: Colors.white, indicatorColor: Colors.transparent,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.folder_rounded), selectedIcon: Icon(Icons.folder_rounded), label: 'Files'),
        NavigationDestination(icon: Icon(Icons.access_time_filled_rounded), selectedIcon: Icon(Icons.access_time_filled_rounded), label: 'Recents'),
        NavigationDestination(icon: Icon(Icons.settings_rounded), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
      ]));

  Widget _library() {
    var data = c.items.toList();
    if (_tab == 1) data = data.where((e) => _favorites ? e.isFavorite : e.isRecent).toList();
    if (_kindFilter != null) data = data.where((e) => e.kind == _kindFilter).toList();
    if (_query.isNotEmpty) data = data.where((e) => e.name.toLowerCase().contains(_query.toLowerCase())).toList();
    data.sort(_compareItems);
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(22, 16, 22, 8), child: TextField(
        controller: _search, onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(hintText: 'Search', hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 18),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8793A0), size: 28),
          filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 15),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE1E1E1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _blue))))),
      Padding(padding: const EdgeInsets.fromLTRB(22, 15, 16, 12), child: Row(children: [
        if (_tab == 0) const Expanded(child: Text('Files', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _ink)))
        else ...[
          _topTab('Recents', !_favorites, () => setState(() { _favorites = false; _kindFilter = null; })),
          const SizedBox(width: 28), _topTab('Favorites', _favorites, () => setState(() { _favorites = true; _kindFilter = null; })),
          const Spacer(),
        ],
        if (_tab == 0) const Spacer(),
        IconButton(tooltip: _grid ? 'List view' : 'Grid view', onPressed: () => setState(() => _grid = !_grid), icon: Icon(_grid ? Icons.grid_view_rounded : Icons.view_list_rounded, color: _ink, size: 27)),
        IconButton(key: _sortButtonKey, tooltip: 'Sort', onPressed: _sort, icon: const Icon(Icons.check_box_outlined, color: _ink, size: 27)),
      ])),
      Expanded(child: c.loading ? const Center(child: CircularProgressIndicator(color: _blue))
        : _tab == 0 ? _fileCategories()
        : data.isEmpty ? _empty()
        : _grid ? GridView.builder(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .76),
            itemCount: data.length, itemBuilder: (_, i) => _card(data[i]))
          : ListView.separated(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), itemCount: data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8), itemBuilder: (_, i) => _row(data[i]))),
    ]);
  }

  Widget _fileCategories() {
    final folders = c.items.where((item) => item.kind == 'folder').toList();
    return GridView.count(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), crossAxisCount: 2,
      crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .76,
      children: [
        _categoryCard('Files', Icons.folder_rounded, const Color(0xFF55C3F0), c.items.where((e) => e.kind == 'pdf').length, () => _pickCategory(imagesOnly: false)),
        _categoryCard('Photos', Icons.image_rounded, const Color(0xFFFFB23F), c.items.where((e) => e.kind == 'image').length, () => _pickCategory(imagesOnly: true)),
        _categoryCard('Trash', Icons.delete_rounded, const Color(0xFFB8BCC2), 0, () => _toast('Trash is empty.')),
        for (final folder in folders)
          _categoryCard(folder.name, Icons.folder_rounded, const Color(0xFF55C3F0), _folderItemCount(folder), () => _open(folder)),
      ],
    );
  }

  int _folderItemCount(LibraryItem folder) {
    try { return Directory(folder.path).listSync(followLinks: false).length; }
    on FileSystemException { return 0; }
  }

  Widget _categoryCard(String title, IconData icon, Color color, int count, VoidCallback onTap) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(18), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Column(
      mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 78, color: color), const SizedBox(height: 30),
        Text(title, style: const TextStyle(fontSize: 17, color: _ink)), const SizedBox(height: 18),
        Text('$count item${count == 1 ? '' : 's'}', style: const TextStyle(fontSize: 13, color: _muted)),
      ])));

  Widget _topTab(String title, bool selected, VoidCallback action) => GestureDetector(onTap: action, child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(title, style: TextStyle(fontSize: 18, fontWeight: selected ? FontWeight.w700 : FontWeight.w400, color: selected ? _ink : _muted)), if (selected) Container(height: 3, width: 42, margin: const EdgeInsets.only(top: 5), decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(2)))])));

  Widget _empty() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(_tab == 0 ? Icons.folder_open_rounded : _favorites ? Icons.favorite_border_rounded : Icons.history_rounded, size: 58, color: const Color(0xFFD0D3D8)),
    const SizedBox(height: 14), Text(_tab == 0 ? 'Your library is empty' : _favorites ? 'No favorites yet' : 'No recent files', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _ink)),
    const SizedBox(height: 6), Text(_tab == 0 ? 'Tap + to add a PDF or photo.' : 'Files you add will appear here.', style: const TextStyle(color: _muted)),
  ])));

  Widget _card(LibraryItem item) => Material(color: Colors.white, borderRadius: BorderRadius.circular(18), child: InkWell(onTap: () => _open(item), onLongPress: () => _actions(item), borderRadius: BorderRadius.circular(18), child: Padding(padding: const EdgeInsets.fromLTRB(10, 10, 10, 8), child: Column(children: [
    Expanded(child: Stack(children: [Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(11), child: _preview(item))),
      Positioned(top: 3, right: 3, child: IconButton(onPressed: () => c.toggleFavorite(item), visualDensity: VisualDensity.compact, icon: Icon(item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: item.isFavorite ? Colors.redAccent : const Color(0xFF9AA0A6), size: 21)))])),
    const SizedBox(height: 9), Text(item.name, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, height: 1.25, color: _ink)),
    const SizedBox(height: 5), Text(_date(item.addedAt), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _muted)),
    SizedBox(height: 27, child: Center(child: Material(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20), child: InkWell(onTap: () => _actions(item), borderRadius: BorderRadius.circular(20), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 13, vertical: 1), child: Icon(Icons.more_horiz_rounded, color: _muted, size: 21))))))
  ]))));

  Widget _preview(LibraryItem item) {
    if (item.kind == 'image') return Image.file(File(item.path), fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_rounded, size: 58, color: Color(0xFFFFB74D)));
    return Container(color: const Color(0xFFFAFAFA), child: Center(child: Icon(item.kind == 'folder' ? Icons.folder_rounded : Icons.picture_as_pdf_rounded, size: item.kind == 'folder' ? 78 : 68, color: item.kind == 'folder' ? const Color(0xFF56C5F0) : const Color(0xFFE95A54))));
  }

  Widget _row(LibraryItem item) => Material(color: Colors.white, borderRadius: BorderRadius.circular(14), child: ListTile(onTap: () => _open(item), leading: SizedBox(width: 48, height: 54, child: _preview(item)), title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: _ink)), subtitle: Text(_date(item.addedAt), style: const TextStyle(color: _muted)), trailing: IconButton(onPressed: () => _actions(item), icon: const Icon(Icons.more_vert_rounded))));

  String _date(DateTime d) { final local = d.toLocal(); const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']; final h = local.hour % 12 == 0 ? 12 : local.hour % 12; final m = local.minute.toString().padLeft(2, '0'); final s = local.second.toString().padLeft(2, '0'); return '${months[local.month - 1]} ${local.day}, ${local.year} $h:$m:$s ${local.hour < 12 ? 'AM' : 'PM'}'; }
  Future<void> _pickCategory({required bool imagesOnly}) async {
    final existingIds = c.items.map((item) => item.id).toSet();
    await c.addFiles(imagesOnly: imagesOnly);
    if (!mounted) return;
    final addedItems = c.items.where((item) => !existingIds.contains(item.id)).toList();
    if (addedItems.isEmpty) return;

    // A PDF chosen from the Files category should enter the reader immediately.
    // Sending the user to Recents first made the picker feel like it had not opened
    // the selected document at all.
    if (!imagesOnly) {
      LibraryItem? selectedPdf;
      for (final item in addedItems) {
        if (item.kind == 'pdf') {
          selectedPdf = item;
          break;
        }
      }
      if (selectedPdf != null) {
        await _open(selectedPdf);
        return;
      }
    }

    setState(() {
      _tab = 1;
      _favorites = false;
      _kindFilter = imagesOnly ? 'image' : 'pdf';
    });
  }

  int _compareItems(LibraryItem a, LibraryItem b) {
    final comparison = switch (_sortField) {
      'name' => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      'size' => _itemSize(a).compareTo(_itemSize(b)),
      _ => a.addedAt.compareTo(b.addedAt),
    };
    return _ascending ? comparison : -comparison;
  }

  int _itemSize(LibraryItem item) {
    try {
      return File(item.path).lengthSync();
    } on FileSystemException {
      return 0;
    }
  }

  Future<void> _open(LibraryItem item) async {
    if (item.path.startsWith('demo:')) { _toast('This is a sample item. Add your own files with +.'); return; }
    if (item.kind == 'folder') {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => FolderContentsScreen(folder: item, controller: c),
      ));
      return;
    }
    if (item.kind == 'pdf') {
      await c.markRecent(item);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PdfWorkspacePage(item: item)));
      return;
    }
    await c.open(item);
  }

  void _addMenu() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFAFAFA),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) => SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Import From', style: TextStyle(fontSize: 15, color: _muted)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _importTile(Icons.image_rounded, 'Photos', () { Navigator.pop(sheetContext); _pickCategory(imagesOnly: true); })),
          const SizedBox(width: 16),
          Expanded(child: _importTile(Icons.folder_rounded, 'Files', () { Navigator.pop(sheetContext); _pickCategory(imagesOnly: false); })),
        ]),
        const SizedBox(height: 26),
        const Text('Create New', style: TextStyle(fontSize: 15, color: _muted)),
        const SizedBox(height: 12),
        _createTile(Icons.document_scanner_outlined, 'Scan', () { Navigator.pop(sheetContext); _scanDocument(); }),
        const SizedBox(height: 10),
        _createTile(Icons.note_add_outlined, 'Create empty PDF', () { Navigator.pop(sheetContext); _createEmptyPdf(); }),
        const SizedBox(height: 10),
        _createTile(Icons.create_new_folder_outlined, 'Create new folder', () { Navigator.pop(sheetContext); _createFolder(); }),
      ]),
    )),
  );

  Widget _importTile(IconData icon, String label, VoidCallback action) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(14),
    child: InkWell(onTap: action, borderRadius: BorderRadius.circular(14), child: Container(
      height: 90, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE8E8E8)), borderRadius: BorderRadius.circular(14)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 36, color: _blue), const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
    )),
  );

  Widget _createTile(IconData icon, String title, VoidCallback action) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(12),
    child: InkWell(onTap: action, borderRadius: BorderRadius.circular(12), child: Container(
      height: 54, padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE8E8E8)), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))), Icon(icon, color: const Color(0xFF555B66))]),
    )),
  );

  Future<void> _scanDocument() async {
    try {
      final photo = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 90);
      if (photo == null || !mounted) return;
      final pdfPath = await PdfActionsController.imageToPdf(photo.path);
      await c.addGeneratedFile(pdfPath, 'Scan-${DateTime.now().millisecondsSinceEpoch}.pdf');
      if (mounted) _toast('Scan saved as a PDF.');
    } catch (error) { if (mounted) _toast('Could not scan: $error'); }
  }

  Future<void> _createEmptyPdf() async {
    try {
      final path = await PdfActionsController.createEmptyPdf();
      await c.addGeneratedFile(path, 'Untitled-${DateTime.now().millisecondsSinceEpoch}.pdf');
      if (mounted) _toast('Empty PDF created.');
    } catch (error) { if (mounted) _toast('Could not create PDF: $error'); }
  }

  Future<void> _createFolder() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Create new folder'),
      content: TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(hintText: 'Folder name')),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, nameController.text.trim()), child: const Text('Create'))],
    ));
    nameController.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await c.createFolder(name);
      if (mounted) _toast('Folder created in your app library.');
    } catch (error) { if (mounted) _toast('Could not create folder: $error'); }
  }

  void _actions(LibraryItem item) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFAFAFA),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 16), child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(contentPadding: EdgeInsets.zero, title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(_date(item.addedAt)), trailing: IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () { Navigator.pop(ctx); _open(item); })),
        const SizedBox(height: 8),
        if (item.kind != 'folder') ...[
          _actionGroup([
            _actionTile('Share', Icons.ios_share_rounded, () { Navigator.pop(ctx); _runAction(() => PdfActionsController.shareLibraryFile(item.path, item.name, isImage: item.kind == 'image')); }),
            _actionTile('Print', Icons.print_outlined, () { Navigator.pop(ctx); _runAction(() => PdfActionsController.printLibraryFile(item.path, isImage: item.kind == 'image')); }),
          ]),
          const SizedBox(height: 12),
        ],
        _actionGroup([
          if (item.kind != 'folder') _actionTile('Convert to PDF', Icons.picture_as_pdf_outlined, () { Navigator.pop(ctx); _convertToPdf(item); }),
          _actionTile(item.isFavorite ? 'Remove from Favorites' : 'Add to Favorites', item.isFavorite ? Icons.star_rounded : Icons.star_border_rounded, () { Navigator.pop(ctx); c.toggleFavorite(item); }),
          _actionTile('Remove from Recents', Icons.remove_circle_outline_rounded, () { Navigator.pop(ctx); c.removeFromRecents(item); }),
        ]),
      ],
    ))),
  );

  Widget _actionGroup(List<Widget> children) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(16), clipBehavior: Clip.antiAlias,
    child: Column(children: [for (var i = 0; i < children.length; i++) ...[
      if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16), children[i],
    ]]),
  );

  Widget _actionTile(String title, IconData icon, VoidCallback action) => ListTile(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: Icon(icon, color: const Color(0xFF555B66)),
    onTap: action,
  );

  Future<void> _convertToPdf(LibraryItem item) async {
    if (item.kind != 'image') { _toast('This file is already a PDF.'); return; }
    try {
      final path = await PdfActionsController.imageToPdf(item.path);
      final dot = item.name.lastIndexOf('.');
      final baseName = dot > 0 ? item.name.substring(0, dot) : item.name;
      await c.addGeneratedFile(path, '$baseName.pdf');
      if (mounted) _toast('PDF added to your library.');
    } catch (error) { if (mounted) _toast('Could not convert image: $error'); }
  }

  Future<void> _runAction(Future<String?> Function() action) async {
    try { final message = await action(); if (message != null && mounted) _toast(message); }
    catch (error) { if (mounted) _toast('Action failed: $error'); }
  }

  Future<void> _sort() async {
    final buttonContext = _sortButtonKey.currentContext;
    if (buttonContext == null) return;

    final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox;
    final buttonBox = buttonContext.findRenderObject() as RenderBox;
    final topLeft = buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final bottomRight = buttonBox.localToGlobal(buttonBox.size.bottomRight(Offset.zero), ancestor: overlayBox);
    final screenSize = overlayBox.size;
    final menuWidth = screenSize.width < 320 ? screenSize.width - 24 : 300.0;
    final left = (bottomRight.dx - menuWidth).clamp(12.0, screenSize.width - menuWidth - 12).toDouble();
    final top = (bottomRight.dy + 8).clamp(12.0, screenSize.height - 390).toDouble();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close layout and sort menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => Material(
        type: MaterialType.transparency,
        child: Stack(children: [
          Positioned(
            left: left,
            top: top,
            child: _sortPopup(dialogContext, menuWidth),
          ),
        ]),
      ),
    );
  }

  Widget _sortPopup(BuildContext dialogContext, double width) => StatefulBuilder(
    builder: (context, refresh) => Material(
      color: const Color(0xFFFAFAFA),
      elevation: 12,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Layout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _muted)),
              const SizedBox(height: 10),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, icon: Icon(Icons.view_list_rounded), label: Text('List')),
                  ButtonSegment(value: true, icon: Icon(Icons.grid_view_rounded), label: Text('Grid')),
                ],
                selected: {_grid},
                onSelectionChanged: (values) {
                  setState(() => _grid = values.first);
                  refresh(() {});
                },
              ),
              const SizedBox(height: 16),
              const Text('Sort By', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _muted)),
              const SizedBox(height: 4),
              for (final (field, label) in [('date', 'Date'), ('name', 'Name'), ('size', 'Size')])
                _sortOption(dialogContext, field, label),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _sortOption(BuildContext dialogContext, String field, String label) {
    final selected = _sortField == field;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          if (_sortField == field) {
            _ascending = !_ascending;
          } else {
            _sortField = field;
            _ascending = field == 'name';
          }
        });
        Navigator.of(dialogContext).pop();
      },
      child: SizedBox(
        height: 48,
        child: Row(children: [
          Icon(selected ? Icons.check_rounded : Icons.sort_rounded, size: 21, color: _ink),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: _ink))),
          if (selected) Icon(_ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 20, color: _ink),
        ]),
      ),
    );
  }

  Widget _settings() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(22, 25, 22, 12), child: Text('Settings', style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.onSurface))),
    _settingRow('Language', widget.language, _chooseLanguage),
    _settingRow('Theme', _themeLabel, _chooseTheme),
    _settingRow('Feedback', '', _openFeedback),
    _settingRow('Follow Us', '', _showFollowDialog),
    _settingRow('Rate', '', _showRateDialog),
    Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.picture_as_pdf_rounded, size: 72, color: Color(0xFF2F80ED)), const SizedBox(height: 10), Text('Version: 1.0', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))]))),
  ]);

  String get _themeLabel => switch (widget.themeMode) {
    ThemeMode.system => 'Auto', ThemeMode.light => 'Light', ThemeMode.dark => 'Dark',
  };

  Widget _settingRow(String title, String value, VoidCallback action) => InkWell(
    onTap: action,
    child: Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant))),
      child: Row(children: [
        Expanded(child: Text(title, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface))),
        if (value.isNotEmpty) Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15)),
        Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ]),
    ),
  );

  Future<void> _chooseLanguage() async {
    final value = await Navigator.of(context).push<String>(MaterialPageRoute(
      builder: (_) => SettingsLanguageScreen(selected: widget.language),
    ));
    if (value != null) widget.onLanguageChanged(value);
  }

  Future<void> _chooseTheme() async {
    final value = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.fromLTRB(20, 4, 20, 12), child: Text('Theme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
        for (final (mode, label) in [(ThemeMode.system, 'Auto'), (ThemeMode.light, 'Light'), (ThemeMode.dark, 'Dark')])
          RadioListTile<ThemeMode>(
            value: mode,
            groupValue: widget.themeMode,
            title: Text(label),
            activeColor: _blue,
            onChanged: (_) => Navigator.pop(sheetContext, mode),
          ),
        const SizedBox(height: 10),
      ])),
    );
    if (value != null) widget.onThemeChanged(value);
  }

  void _openFeedback() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsFeedbackScreen()));

  Future<void> _showFollowDialog() => showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFFAFA), Color(0xFFFFE6E8)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [const Spacer(), const Text('Paper PDF', style: TextStyle(fontSize: 16)), const SizedBox(width: 8), const Icon(Icons.verified_rounded, color: Color(0xFFEF4444)), const Spacer(), IconButton(onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close_rounded))]),
          const SizedBox(height: 8),
          const Text('Support Paper', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const Text('Share the project with someone who may find it useful.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6F7378), fontSize: 15)),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await SharePlus.instance.share(ShareParams(text: 'Paper PDF project: https://github.com/infoqadir56-droid/PDF_EDIT_APP'));
            },
            icon: const Icon(Icons.share_rounded), label: const Text('SHARE PROJECT'),
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _ink, minimumSize: const Size.fromHeight(54)),
          )),
        ]),
      ),
    ),
  );

  Future<void> _showRateDialog() => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Rate Paper PDF'),
      content: const Text('The app does not have a Play Store listing yet. You can send feedback from Settings to help improve it.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        FilledButton(onPressed: () { Navigator.pop(dialogContext); _openFeedback(); }, child: const Text('Send feedback')),
      ],
    ),
  );
}

