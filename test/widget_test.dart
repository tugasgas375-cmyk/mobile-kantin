import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kasir_app/main.dart';

void main() {
  testWidgets('Login page renders and logout returns to login', (WidgetTester tester) async {
    await tester.pumpWidget(const KasirApp());

    expect(find.text('Aplikasi Kasir'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(FilledButton), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'kasir');
    await tester.enterText(find.byType(TextField).at(1), 'kasir');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    await tester.tap(find.byTooltip('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Aplikasi Kasir'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
