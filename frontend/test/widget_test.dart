import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_companion/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCampusCompanion());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}