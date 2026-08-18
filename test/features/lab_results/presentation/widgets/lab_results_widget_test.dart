import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_theme.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/di/lab_results_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/utils/lab_value_formatter.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_card.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_chart_pane.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

final _tNumericWithRange = LabResultEntity(
  id: 'lr_0001',
  testCode: 'HB',
  testName: 'Hemoglobina',
  category: 'Hematología',
  unit: 'g/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 13.0, high: 17.0),
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: 16.8,
      textValue: null,
    ),
    LabResultValueEntity(
      date: DateTime(2026, 6, 14),
      value: 15.4,
      textValue: null,
    ),
  ],
);

final _tNumericNoRange = LabResultEntity(
  id: 'lr_0003',
  testCode: 'CREA',
  testName: 'Creatinina',
  category: 'Química',
  unit: 'mg/dL',
  kind: LabResultKind.numeric,
  referenceRange: null,
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: 1.2,
      textValue: null,
    ),
  ],
);

final _tText = LabResultEntity(
  id: 'lr_0004',
  testCode: 'GRUPO',
  testName: 'Grupo sanguíneo',
  category: 'Inmunohematología',
  unit: null,
  kind: LabResultKind.text,
  referenceRange: null,
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: null,
      textValue: 'A Positivo (A+)',
    ),
  ],
);

Widget _buildCard(LabResultEntity result) => MaterialApp(
  theme: AppTheme.material3,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: LabResultsCard(result: result)),
);

class _FakeTrendChart implements ITrendChart {
  @override
  Widget lineChart({required TrendChartData data}) => const SizedBox.shrink();
}

Widget _buildChartPane(LabResultEntity result) => ProviderScope(
  overrides: [trendChartProvider.overrideWithValue(_FakeTrendChart())],
  child: MaterialApp(
    theme: AppTheme.material3,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: LabResultsChartPane(result: result, period: Period.all),
    ),
  ),
);

void main() {
  group('LabResultsCard', () {
    testWidgets('numeric card shows value, unit and status chip', (
      tester,
    ) async {
      await tester.pumpWidget(_buildCard(_tNumericWithRange));
      await tester.pump();

      expect(find.text('Hemoglobina'), findsOneWidget);
      expect(find.text('16.8'), findsOneWidget);
      expect(find.text('g/dL'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.byType(InfoChip), findsOneWidget);
    });

    testWidgets('numeric card exposes a semantics label for the latest value', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildCard(_tNumericWithRange));
      await tester.pump();

      final semantics = tester.getSemantics(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label?.contains('Latest') == true,
        ),
      );
      expect(semantics.label, contains('Latest: 16.8 g/dL'));
      handle.dispose();
    });

    testWidgets('numeric card without range shows Unknown chip', (
      tester,
    ) async {
      await tester.pumpWidget(_buildCard(_tNumericNoRange));
      await tester.pump();

      expect(find.text('1.2'), findsOneWidget);
      expect(find.text('mg/dL'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.byType(InfoChip), findsOneWidget);
    });

    testWidgets('non-numeric card shows text and no status chip', (
      tester,
    ) async {
      await tester.pumpWidget(_buildCard(_tText));
      await tester.pump();

      expect(find.text('Grupo sanguíneo'), findsOneWidget);
      expect(find.text('A Positivo (A+)'), findsOneWidget);
      expect(find.byType(InfoChip), findsNothing);
    });
  });

  group('formatLabValue', () {
    test('trims trailing zeros and keeps up to 2 decimals', () {
      expect(formatLabValue(2.0), '2');
      expect(formatLabValue(2.34), '2.34');
      expect(formatLabValue(3.5), '3.5');
      expect(formatLabValue(128.0), '128');
    });
  });

  group('LabResultsChartPane', () {
    testWidgets('chart is wrapped in horizontal padding matching the cards', (
      tester,
    ) async {
      await tester.pumpWidget(_buildChartPane(_tNumericWithRange));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(LabResultsChartPane),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Padding &&
                w.padding == const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        findsOneWidget,
      );
    });
  });
}
