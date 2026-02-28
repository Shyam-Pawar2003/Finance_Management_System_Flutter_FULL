// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

// import the real app entrypoint so we can pump the widget tree
import '../lib/main.dart';
import '../lib/screens/login_screen.dart';

void main() {
  testWidgets('App launches and shows login screen',
      (WidgetTester tester) async {
    // Build the FinanceApp and trigger a frame.
    await tester.pumpWidget(const FinanceApp());

    // The login screen should be displayed by default.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
