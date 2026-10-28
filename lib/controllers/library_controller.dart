import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/library_item.dart';

class LibraryController extends ChangeNotifier {
  static const _storageKey = 'paper.library.v1';
  List<LibraryItem> items = [];
  bool loading = true;
  String? error;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        items = decoded.map((e) => LibraryItem.fromJson(e as Map<String, dynamic>))
            .where((e) => e.path.startsWith('demo:') || File(e.path).existsSync()).toList();
      }
    } catch (_) { error = 'Could not load your saved library.'; }
    loading = false;
    notifyListeners();
  }

  Future<void> addFiles({bool imagesOnly = false}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: imagesOnly ? FileType.image : FileType.custom,
        allowedExtensions: imagesOnly ? null : ['pdf', 'png', 'jpg', 'jpeg', 'webp', 'gif']);
      if (result == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final libraryDir = Directory('${dir.path}${Platform.pathSeparator}paper_library');
      await libraryDir.create(recursive: true);
      for (final file in result.files) {
        if (file.path == null) continue;
        final source = File(file.path!);
        final safeName = file.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        var destination = '${libraryDir.path}${Platform.pathSeparator}$safeName';
        if (File(destination).existsSync()) {
          final dot = safeName.lastIndexOf('.');
          final stem = dot > 0 ? safeName.substring(0, dot) : safeName;
          final ext = dot > 0 ? safeName.substring(dot) : '';
          destination = '${libraryDir.path}${Platform.pathSeparator}$stem-${DateTime.now().microsecondsSinceEpoch}$ext';
        }
        final copied = await source.copy(destination);
        items.insert(0, LibraryItem(id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: safeName, path: copied.path,
          kind: _isImage(safeName) ? 'image' : 'pdf', addedAt: DateTime.now()));
      }
      await _save();
    } catch (_) { error = 'Could not add the selected files.'; notifyListeners(); }
  }

  Future<void> toggleFavorite(LibraryItem item) async {
    items = items.map((e) => e.id == item.id ? e.copyWith(isFavorite: !e.isFavorite) : e).toList();
    await _save();
  }

  Future<void> remove(LibraryItem item) async {
    items.removeWhere((e) => e.id == item.id);
    try { if (!item.path.startsWith('demo:')) await File(item.path).delete(); } catch (_) {}
    await _save();
  }

  Future<void> open(LibraryItem item) async {
    if (item.path.startsWith('demo:')) return;
    await markRecent(item);
    await OpenFilex.open(item.path);
  }

  Future<void> markRecent(LibraryItem item) async {
    if (item.path.startsWith('demo:')) return;
    items = items.map((e) => e.id == item.id ? e.copyWith(addedAt: DateTime.now()) : e).toList();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(items.map((e) => e.toJson()).toList()));
      error = null;
    } catch (_) { error = 'Could not save your library.'; }
    notifyListeners();
  }
  bool _isImage(String name) => ['.png', '.jpg', '.jpeg', '.webp', '.gif']
      .any(name.toLowerCase().endsWith);
}
