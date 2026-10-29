// Basic Flutter widget test for PdfStudioApp.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdf_app_project/main.dart';

void main() {
  testWidgets('PdfStudioApp renders the file library categories', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PdfStudioApp());
    await tester.pumpAndSettle();

    expect(find.text('Photos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Trash'),
      250,
      scrollable: find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Trash'), findsOneWidget);
    expect(find.byTooltip('Sort'), findsOneWidget);
  });
}
