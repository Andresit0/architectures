import 'package:clean_architecture_sdd_harness/design_system/components/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InfoChip', () {
    testWidgets('renders label and optional icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoChip(label: 'Available', icon: Icons.check),
          ),
        ),
      );

      expect(find.text('Available'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('applies the provided background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoChip(label: 'Available', color: Colors.green),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(InfoChip),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, Colors.green);
    });

    testWidgets('works without icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InfoChip(label: 'Closed')),
        ),
      );

      expect(find.text('Closed'), findsOneWidget);
    });
  });
}
