import 'package:flutter/material.dart';

enum PdfPaperTheme { original, bright, night, green, sepia }

class PdfViewSettings {
  const PdfViewSettings({this.horizontal = false, this.brightness = 0, this.theme = PdfPaperTheme.original});
  final bool horizontal;
  final double brightness;
  final PdfPaperTheme theme;

  Color get background => switch (theme) {
    PdfPaperTheme.original || PdfPaperTheme.bright => Colors.white,
    PdfPaperTheme.night => const Color(0xFF242424),
    PdfPaperTheme.green => const Color(0xFFCFF4D2),
    PdfPaperTheme.sepia => const Color(0xFFFFEDC2),
  };

  Map<String, Object> toJson() => {'horizontal': horizontal, 'brightness': brightness, 'theme': theme.index};
  factory PdfViewSettings.fromJson(Map<String, dynamic> json) => PdfViewSettings(
    horizontal: json['horizontal'] as bool? ?? false,
    brightness: (json['brightness'] as num?)?.toDouble() ?? 0,
    theme: PdfPaperTheme.values[(json['theme'] as int? ?? 0).clamp(0, PdfPaperTheme.values.length - 1).toInt()],
  );
}
