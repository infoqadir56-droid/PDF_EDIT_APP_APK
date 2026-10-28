import 'package:flutter/material.dart';
import 'controllers/library_controller.dart';
import 'views/library_page.dart';

void main() => runApp(const PdfStudioApp());

class PdfStudioApp extends StatefulWidget {
  const PdfStudioApp({super.key});
  @override
  State<PdfStudioApp> createState() => _PdfStudioAppState();
}

class _PdfStudioAppState extends State<PdfStudioApp> {
  late final LibraryController controller;
  @override
  void initState() {
    super.initState();
    controller = LibraryController()..load();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Paper — File manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F80ED)),
          fontFamily: 'Roboto',
        ),
        home: LibraryPage(controller: controller),
      );
}
