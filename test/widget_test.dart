// Basic Flutter widget test for PdfStudioApp.

import 'package:flutter_test/flutter_test.dart';

import 'package:pdf_app_project/main.dart';

void main() {
  testWidgets('PdfStudioApp renders app header and documents', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PdfStudioApp());

    // Verify header text and document entries exist.
    expect(find.text('paper'), findsOneWidget);
    expect(find.text('Project proposal 2026.pdf'), findsOneWidget);
  });
}
