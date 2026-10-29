// Basic Flutter widget test for PdfStudioApp.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdf_app_project/main.dart';

void main() {
  testWidgets('PdfStudioApp renders the file library categories', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PdfStudioApp());
    await tester.pumpAndSettle();

    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Trash'), findsOneWidget);
    expect(find.byTooltip('Sort'), findsOneWidget);
  });
}
