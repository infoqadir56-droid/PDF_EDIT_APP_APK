import 'dart:io';
import 'package:flutter/material.dart';
import '../controllers/library_controller.dart';
import '../models/library_item.dart';
import 'pdf_workspace_page.dart';

class FolderContentsScreen extends StatefulWidget {
  const FolderContentsScreen({super.key, required this.folder, required this.controller});
  final LibraryItem folder;
  final LibraryController controller;

  @override
  State<FolderContentsScreen> createState() => _FolderContentsScreenState();
}

class _FolderContentsScreenState extends State<FolderContentsScreen> {
  @override
  void initState() { super.initState(); widget.controller.addListener(_refresh); }
  @override
  void dispose() { widget.controller.removeListener(_refresh); super.dispose(); }
  void _refresh() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.items.where((item) =>
      item.kind != 'folder' && File(item.path).parent.path == widget.folder.path).toList();
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name), actions: [
        IconButton(tooltip: 'Add files', icon: const Icon(Icons.add), onPressed: () => widget.controller.addFiles(targetDirectory: widget.folder.path)),
      ]),
      body: items.isEmpty
        ? const Center(child: Text('This folder is empty. Tap + to add files.'))
        : ListView.builder(itemCount: items.length, itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Icon(item.kind == 'pdf' ? Icons.picture_as_pdf_outlined : Icons.image_outlined),
              title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () async {
                if (item.kind != 'pdf') return;
                await widget.controller.markRecent(item);
                if (!context.mounted) return;
                await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PdfWorkspacePage(item: item)));
              },
            );
          }),
    );
  }
}
