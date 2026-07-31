import 'package:clean_architecture_sdd_harness/design_system/components/loading_indicator.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('renders CircularProgressIndicator wrapped in Center', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('uses primary color from AppColors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      final circularProgress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(circularProgress.color, AppColors.primary);
      expect(circularProgress.strokeWidth, 4.0);
    });

    testWidgets('can be used as a const widget', (tester) async {
      const widget = LoadingIndicator();
      expect(widget, isA<LoadingIndicator>());

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: widget)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
