// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:agop_finalyear/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App loads and shows company name on login page', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    // Build the real app so Material widgets are available.
    await tester.pumpWidget(const GroundOperationsApp());
    await tester.pumpAndSettle();

    // Verify the login page shows the company name from COMPANY_INFO
    expect(find.text('Airport Services'), findsOneWidget);
  });
}
