import 'package:flutter/material.dart';
import '../models/pdf_view_settings.dart';

class PdfViewSettingsScreen extends StatefulWidget {
  const PdfViewSettingsScreen({super.key, required this.initial});
  final PdfViewSettings initial;
  @override
  State<PdfViewSettingsScreen> createState() => _PdfViewSettingsScreenState();
}

class _PdfViewSettingsScreenState extends State<PdfViewSettingsScreen> {
  late PdfViewSettings value = widget.initial;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFAFAFA),
    appBar: AppBar(title: const Text('View Settings'), actions: [TextButton(onPressed: () => Navigator.pop(context, value), child: const Text('Done'))]),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Page direction', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      SegmentedButton<bool>(segments: const [ButtonSegment(value: false, label: Text('Vertical'), icon: Icon(Icons.swap_vert)), ButtonSegment(value: true, label: Text('Horizontal'), icon: Icon(Icons.swap_horiz))], selected: {value.horizontal}, onSelectionChanged: (s) => setState(() => value = PdfViewSettings(horizontal: s.first, brightness: value.brightness, theme: value.theme))),
      const SizedBox(height: 28),
      const Text('Brightness', style: TextStyle(fontWeight: FontWeight.w700)),
      Slider(value: value.brightness, min: -0.35, max: 0.35, onChanged: (v) => setState(() => value = PdfViewSettings(horizontal: value.horizontal, brightness: v, theme: value.theme))),
      const SizedBox(height: 18),
      const Text('Paper theme', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Wrap(spacing: 12, runSpacing: 12, children: PdfPaperTheme.values.map((theme) => InkWell(onTap: () => setState(() => value = PdfViewSettings(horizontal: value.horizontal, brightness: value.brightness, theme: theme)), child: Container(width: 60, height: 60, decoration: BoxDecoration(color: _color(theme), borderRadius: BorderRadius.circular(14), border: Border.all(color: theme == value.theme ? const Color(0xFF2F80ED) : const Color(0xFFE8E8E8), width: theme == value.theme ? 2 : 1)), child: Icon(_icon(theme), size: 23, color: theme == PdfPaperTheme.night ? Colors.white : Colors.black54)))).toList()),
    ]),
  );
  Color _color(PdfPaperTheme t) => switch (t) { PdfPaperTheme.original => const Color(0xFFE3E3E3), PdfPaperTheme.bright => Colors.white, PdfPaperTheme.night => const Color(0xFF171717), PdfPaperTheme.green => const Color(0xFFCFF4D2), PdfPaperTheme.sepia => const Color(0xFFFFEDC2) };
  IconData _icon(PdfPaperTheme t) => switch (t) { PdfPaperTheme.original => Icons.brightness_auto, PdfPaperTheme.bright => Icons.wb_sunny_outlined, PdfPaperTheme.night => Icons.nightlight_round, PdfPaperTheme.green => Icons.circle, PdfPaperTheme.sepia => Icons.circle };
}
