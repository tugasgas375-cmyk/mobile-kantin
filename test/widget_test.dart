import 'package:flutter_test/flutter_test.dart';

import 'package:kasir_app/main.dart';

void main() {
  testWidgets('Role selection displays all roles', (WidgetTester tester) async {
    await tester.pumpWidget(const KantinApp());

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Kasir'), findsOneWidget);
  });

  testWidgets('Customer role opens menu page', (WidgetTester tester) async {
    await tester.pumpWidget(const KantinApp());
    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerPage), findsOneWidget);
  });

  testWidgets('Admin login rejects invalid credentials', (WidgetTester tester) async {
    await tester.pumpWidget(const KantinApp());
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'salah');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Username atau password tidak sesuai dengan role.'), findsOneWidget);
  });
}
