import 'package:clean_architecture_sdd_harness/design_system/components/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorState', () {
    testWidgets('renders error icon, message and action button', (
      tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'No internet connection',
              actionLabel: 'Retry',
              onActionPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(pressed, isTrue);
    });

    testWidgets('renders optional title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(title: 'Something failed', message: 'Try again'),
          ),
        ),
      );

      expect(find.text('Something failed'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('hides action button when actionLabel is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ErrorState(message: 'Try again')),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
