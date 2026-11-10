import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kasir_app/main.dart';

void main() {
  testWidgets('app loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KantinApp());

    expect(find.text('Mobile Kantin'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
