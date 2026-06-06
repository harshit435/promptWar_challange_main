import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_wellness_flutter_web/main.dart';
import 'package:mental_wellness_flutter_web/screens/main_navigation.dart';
import 'package:mental_wellness_flutter_web/services/state_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the login screen first', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Enter app'), findsOneWidget);
  });

  testWidgets('skip sign in continues to the main shell',
      (WidgetTester tester) async {
    await StateManager().init();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip sign in and continue'));
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationShell), findsOneWidget);
  });
}
