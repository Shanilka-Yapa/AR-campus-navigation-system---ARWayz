import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arwayz/main.dart';

void main() {
  testWidgets('app shows the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
