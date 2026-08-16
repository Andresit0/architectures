import 'package:clean_architecture_sdd_harness/design_system/components/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders title, message, icon and action button', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Nothing here',
              message: 'Add something',
              icon: Icons.inbox_outlined,
              actionLabel: 'Retry',
              onActionPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Add something'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(pressed, isTrue);
    });

    testWidgets('hides action button when actionLabel is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EmptyState(title: 'Nothing here')),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
