import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'Auto';
  @override
  void initState() {
    super.initState();
    controller = LibraryController()..load();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _language = prefs.getString('settings.language') ?? 'Auto';
      _themeMode = switch (prefs.getString('settings.theme') ?? 'system') {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    });
  }

  Future<void> _setLanguage(String language) async {
    setState(() => _language = language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings.language', language);
  }

  Future<void> _setTheme(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString('settings.theme', value);
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
          textTheme: ThemeData.light().textTheme.apply(
            bodyColor: const Color(0xFF202124),
            displayColor: const Color(0xFF202124),
            fontFamily: 'Roboto',
          ),
          splashColor: const Color(0x142F80ED),
          highlightColor: const Color(0x0A2F80ED),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF121318),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2F80ED),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
        ),
        themeMode: _themeMode,
        home: LibraryPage(
          controller: controller,
          language: _language,
          themeMode: _themeMode,
          onLanguageChanged: _setLanguage,
          onThemeChanged: _setTheme,
        ),
      );
}
