import 'package:flutter_test/flutter_test.dart';

import 'package:kasir_app/main.dart';

void main() {
  testWidgets('Login page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KasirApp());
    expect(find.text('Aplikasi Kasir'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
