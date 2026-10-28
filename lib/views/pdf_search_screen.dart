import 'package:flutter/material.dart';

class PdfSearchScreen extends StatefulWidget {
  const PdfSearchScreen({super.key, required this.fileName});

  final String fileName;

  @override
  State<PdfSearchScreen> createState() => _PdfSearchScreenState();
}

class _PdfSearchScreenState extends State<PdfSearchScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 58,
                child: Row(children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Color(0xFF2F80ED), fontSize: 16),
                    ),
                  ),
                  const Spacer(),
                  const Text('Search', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const SizedBox(width: 68),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                child: TextField(
                  controller: _search,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8793A0)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.search_off_rounded, size: 82, color: Color(0xFFBDBDBD)),
                    const SizedBox(height: 22),
                    const Text('No matches found', style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 20)),
                    const SizedBox(height: 7),
                    if (_search.text.isNotEmpty)
                      Text('Search in ${widget.fileName}', style: const TextStyle(color: Colors.black38, fontSize: 12)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
}
