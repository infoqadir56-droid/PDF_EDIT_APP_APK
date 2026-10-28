import 'dart:io';
import 'package:flutter/material.dart';
import '../controllers/library_controller.dart';
import '../models/library_item.dart';
import 'pdf_workspace_page.dart';

const _blue = Color(0xFF2F80ED), _ink = Color(0xFF171717), _muted = Color(0xFF9A9A9A);

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, required this.controller});
  final LibraryController controller;
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _tab = 0;
  bool _favorites = false, _grid = true, _ascending = false;
  String? _kindFilter;
  String _query = '';
  final _search = TextEditingController();
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
    if (_tab == 1) data = data.where((e) => _favorites ? e.isFavorite : true).toList();
    if (_kindFilter != null) data = data.where((e) => e.kind == _kindFilter).toList();
    if (_query.isNotEmpty) data = data.where((e) => e.name.toLowerCase().contains(_query.toLowerCase())).toList();
    data.sort((a,b) => _ascending ? a.name.toLowerCase().compareTo(b.name.toLowerCase()) : b.addedAt.compareTo(a.addedAt));
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
        IconButton(tooltip: 'Sort', onPressed: _sort, icon: const Icon(Icons.check_box_outlined, color: _ink, size: 27)),
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

  Widget _fileCategories() => GridView.count(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), crossAxisCount: 2,
    crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .76,
    children: [
      _categoryCard('Files', Icons.folder_rounded, const Color(0xFF55C3F0), c.items.where((e) => e.kind == 'pdf').length, () { setState(() { _tab = 1; _favorites = false; _kindFilter = 'pdf'; }); }),
      _categoryCard('Photos', Icons.image_rounded, const Color(0xFFFFB23F), c.items.where((e) => e.kind == 'image').length, () { setState(() { _tab = 1; _favorites = false; _kindFilter = 'image'; }); }),
      _categoryCard('Trash', Icons.delete_rounded, const Color(0xFFB8BCC2), 0, () => _toast('Trash is empty.')),
    ]);

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

  String _date(DateTime d) { final local = d.toLocal(); const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']; final h = local.hour % 12 == 0 ? 12 : local.hour % 12; final m = local.minute.toString().padLeft(2, '0'); return '${months[local.month - 1]} ${local.day}, ${local.year} ${h.toString().padLeft(2, '0')}:$m ${local.hour < 12 ? 'AM' : 'PM'}'; }
  void _open(LibraryItem item) async {
    if (item.path.startsWith('demo:')) { _toast('This is a sample item. Add your own files with +.'); return; }
    if (item.kind == 'pdf') {
      await c.markRecent(item);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PdfWorkspacePage(item: item)));
      return;
    }
    await c.open(item);
  }

  void _addMenu() => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Add to your library', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
    const SizedBox(height: 12), ListTile(leading: const Icon(Icons.picture_as_pdf_rounded, color: _blue), title: const Text('PDF or document'), subtitle: const Text('Choose files from your device'), onTap: () { Navigator.pop(ctx); c.addFiles(); }),
    ListTile(leading: const Icon(Icons.photo_library_rounded, color: _blue), title: const Text('Photos'), subtitle: const Text('Add images to your library'), onTap: () { Navigator.pop(ctx); c.addFiles(imagesOnly: true); }),
  ]))));

  void _actions(LibraryItem item) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    ListTile(leading: const Icon(Icons.open_in_new_rounded), title: const Text('Open'), onTap: () { Navigator.pop(ctx); _open(item); }),
    ListTile(leading: Icon(item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.redAccent), title: Text(item.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'), onTap: () { Navigator.pop(ctx); c.toggleFavorite(item); }),
    ListTile(leading: const Icon(Icons.delete_outline_rounded, color: Colors.red), title: const Text('Remove from library', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(ctx); c.remove(item); }),
  ])));

  void _sort() => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 26), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Layout', style: TextStyle(fontWeight: FontWeight.w700, color: _muted)), const SizedBox(height: 10),
    SegmentedButton<bool>(segments: const [ButtonSegment(value: false, icon: Icon(Icons.view_list_rounded), label: Text('List')), ButtonSegment(value: true, icon: Icon(Icons.grid_view_rounded), label: Text('Grid'))], selected: {_grid}, onSelectionChanged: (v) { setState(() => _grid = v.first); refresh(() {}); }),
    const SizedBox(height: 18), const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w700, color: _muted)),
    for (final (label, value) in [('Date', false), ('Name', true)]) ListTile(contentPadding: EdgeInsets.zero, leading: Icon(_ascending == value ? Icons.check_rounded : Icons.sort_rounded), title: Text(label), trailing: _ascending == value ? Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward) : null, onTap: () { setState(() => _ascending = value); refresh(() {}); }),
  ]))));

  Widget _settings() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Padding(padding: EdgeInsets.fromLTRB(22, 25, 22, 12), child: Text('Settings', style: TextStyle(fontSize: 24, color: _ink))),
    _settingRow('Language', 'Auto', () => _toast('Language: Auto')),
    _settingRow('Theme', 'Auto', () => _toast('Theme: Auto')),
    _settingRow('Feedback', '', () => _toast('Thanks for helping improve Paper.')),
    _settingRow('Follow Us', '', () => _toast('Paper PDF')),
    _settingRow('Rate', '', () => _toast('Thank you for using Paper.')),
    const Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.picture_as_pdf_rounded, size: 72, color: Colors.redAccent), SizedBox(height: 10), Text('Version: 1.0', style: TextStyle(color: _muted))]))),
  ]);
  Widget _settingRow(String title, String value, VoidCallback action) => InkWell(onTap: action, child: Container(height: 65, padding: const EdgeInsets.symmetric(horizontal: 22), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 16, color: _ink))), if (value.isNotEmpty) Text(value, style: const TextStyle(color: _muted, fontSize: 15)), if (value.isNotEmpty) const Icon(Icons.chevron_right_rounded, color: _muted)])));
}

