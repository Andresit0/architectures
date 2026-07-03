import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/configs/_configs.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/widgets/_widgets.lib.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('renders CircularProgressIndicator wrapped in Center', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CustomWidgets.createLoadingIndicator)),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('uses primary color from CustomConfigs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CustomWidgets.createLoadingIndicator)),
      );

      final circularProgress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(circularProgress.color, CustomConfigs.appColors.primary);
      expect(circularProgress.strokeWidth, 4.0);
    });

    testWidgets('can be used as a const widget', (tester) async {
      const widget = CustomWidgets.createLoadingIndicator;
      expect(widget, isA<LoadingIndicator>());

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: widget)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
