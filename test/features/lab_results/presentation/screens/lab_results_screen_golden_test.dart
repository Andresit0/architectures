@Tags(['golden'])
library;

import 'package:clean_architecture_sdd_harness/features/lab_results/di/lab_results_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_state.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/screens/lab_results_screen.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

class _FakeLabResultsNotifier extends LabResultsNotifier {
  _FakeLabResultsNotifier(this._initial) : super();

  final LabResultsState _initial;

  @override
  LabResultsState build() => _initial;

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh() async {}

  @override
  void selectTest(String id) {}

  @override
  void setPeriod(Period period) {}

  @override
  void reset() {}
}

class _FakeTrendChart implements ITrendChart {
  @override
  Widget lineChart({required TrendChartData data}) => const SizedBox.shrink();
}

final _tNumericHb = LabResultEntity(
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
    LabResultValueEntity(
      date: DateTime(2025, 1, 20),
      value: 12.1,
      textValue: null,
    ),
  ],
);

final _tNumericGlu = LabResultEntity(
  id: 'lr_0002',
  testCode: 'GLU',
  testName: 'Glucosa',
  category: 'Química',
  unit: 'mg/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 70.0, high: 110.0),
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: 128.0,
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

final _tTextGroup = LabResultEntity(
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

final _tMixed = [_tNumericHb, _tNumericGlu, _tNumericNoRange, _tTextGroup];

Widget _buildScreen(LabResultsState state) {
  return ProviderScope(
    overrides: [
      labResultsProvider.overrideWith(() => _FakeLabResultsNotifier(state)),
      trendChartProvider.overrideWithValue(_FakeTrendChart()),
    ],
    child: MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LabResultsScreen(),
    ),
  );
}

void main() {
  testGoldens('LabResultsScreen golden test — loading state', (tester) async {
    await tester.pumpWidget(_buildScreen(const LabResultsLoading()));
    await tester.pump();

    await expectLater(
      find.byType(LabResultsScreen),
      matchesGoldenFile('goldens/lab_results_screen_loading.png'),
    );
  });

  testGoldens('LabResultsScreen golden test — loaded state', (tester) async {
    await tester.pumpWidget(
      _buildScreen(
        LabResultsLoaded(
          results: _tMixed,
          selectedTestId: 'lr_0001',
          period: Period.all,
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(LabResultsScreen),
      matchesGoldenFile('goldens/lab_results_screen_loaded.png'),
    );
  });

  testGoldens('LabResultsScreen golden test — empty state', (tester) async {
    await tester.pumpWidget(
      _buildScreen(
        LabResultsLoaded(
          results: const <LabResultEntity>[],
          selectedTestId: null,
          period: Period.all,
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(LabResultsScreen),
      matchesGoldenFile('goldens/lab_results_screen_empty.png'),
    );
  });

  testGoldens('LabResultsScreen golden test — all non-numeric state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(
        LabResultsLoaded(
          results: [_tTextGroup],
          selectedTestId: null,
          period: Period.all,
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(LabResultsScreen),
      matchesGoldenFile('goldens/lab_results_screen_non_numeric.png'),
    );
  });
}
