import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_theme.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/di/lab_results_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/value_objects/period.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_refresh_error_provider.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/notifiers/lab_results_state.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/screens/lab_results_screen.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_card.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_chart_pane.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_non_numeric_list.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_period_filter.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/widgets/lab_results_test_selector.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class _FakeLabResultsNotifier extends LabResultsNotifier {
  _FakeLabResultsNotifier(this._initial) : super();

  final LabResultsState _initial;
  int loadCallCount = 0;
  int refreshCallCount = 0;
  int resetCallCount = 0;

  @override
  LabResultsState build() => _initial;

  @override
  Future<void> load() async {
    loadCallCount++;
  }

  @override
  Future<void> refresh() async {
    refreshCallCount++;
  }

  @override
  void reset() {
    resetCallCount++;
    state = const LabResultsInitial();
  }

  @override
  void selectTest(String id) {
    final current = state;
    if (current is LabResultsLoaded) {
      state = LabResultsLoaded(
        results: current.results,
        selectedTestId: id,
        period: current.period,
      );
    }
  }

  @override
  void setPeriod(Period period) {
    final current = state;
    if (current is LabResultsLoaded) {
      state = LabResultsLoaded(
        results: current.results,
        selectedTestId: current.selectedTestId,
        period: period,
      );
    }
  }
}

class _FakeTrendChart implements ITrendChart {
  final List<TrendChartData> rendered = [];

  @override
  Widget lineChart({required TrendChartData data}) {
    rendered.add(data);
    return const SizedBox.shrink();
  }
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
final _tOnlyText = <LabResultEntity>[_tTextGroup];

LabResultsLoaded _loaded(List<LabResultEntity> results, {String? selected}) =>
    LabResultsLoaded(
      results: results,
      selectedTestId: selected,
      period: Period.all,
    );

Widget _buildScreen({
  LabResultsState state = const LabResultsInitial(),
  _FakeLabResultsNotifier? notifier,
  _FakeTrendChart? chart,
  ProviderContainer? container,
}) {
  final fake = notifier ?? _FakeLabResultsNotifier(state);
  final effectiveContainer =
      container ??
      ProviderContainer(
        overrides: [
          labResultsProvider.overrideWith(() => fake),
          trendChartProvider.overrideWithValue(chart ?? _FakeTrendChart()),
        ],
      );
  return UncontrolledProviderScope(
    container: effectiveContainer,
    child: MaterialApp(
      theme: AppTheme.material3,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LabResultsScreen(),
    ),
  );
}

void main() {
  testWidgets('shows skeleton list when state is loading', (tester) async {
    await tester.pumpWidget(_buildScreen(state: const LabResultsLoading()));
    await tester.pump();

    expect(find.byType(SkeletonList), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    'loaded shows selector, period filter and cards with status chips',
    (tester) async {
      final chart = _FakeTrendChart();
      await tester.pumpWidget(
        _buildScreen(
          state: _loaded(_tMixed, selected: 'lr_0001'),
          chart: chart,
        ),
      );
      await tester.pump();

      expect(find.byType(LabResultsTestSelector), findsOneWidget);
      expect(find.byType(LabResultsPeriodFilter), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Period'), findsOneWidget);

      expect(find.byType(LabResultsCard), findsNWidgets(3));
      expect(find.byType(LabResultsChartPane), findsOneWidget);

      expect(find.text('16.8'), findsOneWidget);
      expect(find.text('g/dL'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.text('1.2'), findsOneWidget);
      expect(find.text('mg/dL'), findsNWidgets(2));

      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);

      expect(find.byType(LabResultsNonNumericList), findsOneWidget);
      expect(find.text('A Positivo (A+)'), findsOneWidget);

      expect(chart.rendered, isNotEmpty);
      expect(chart.rendered.last.referenceLow, 13.0);
      expect(chart.rendered.last.referenceHigh, 17.0);
    },
  );

  testWidgets('selecting a numeric test renders its chart pane data', (
    tester,
  ) async {
    final chart = _FakeTrendChart();
    await tester.pumpWidget(
      _buildScreen(
        state: _loaded(_tMixed, selected: 'lr_0001'),
        chart: chart,
      ),
    );
    await tester.pump();

    expect(chart.rendered.last.referenceLow, 13.0);

    await tester.tap(
      find.descendant(
        of: find.byType(LabResultsTestSelector),
        matching: find.text('Glucosa'),
      ),
    );
    await tester.pump();

    expect(chart.rendered, isNotEmpty);
    final data = chart.rendered.last;
    expect(data.referenceLow, 70.0);
    expect(data.referenceHigh, 110.0);
    expect(data.unit, 'mg/dL');
    expect(data.points.map((p) => p.value), contains(128.0));
  });

  testWidgets('chart pane hides when no numeric test is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(state: _loaded(_tOnlyText, selected: null)),
    );
    await tester.pump();

    expect(find.byType(LabResultsChartPane), findsNothing);
    expect(find.byType(LabResultsNonNumericList), findsOneWidget);
  });

  testWidgets('all non-numeric results hide selector and period filter', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(state: _loaded(_tOnlyText, selected: null)),
    );
    await tester.pump();

    expect(find.byType(LabResultsTestSelector), findsNothing);
    expect(find.byType(LabResultsPeriodFilter), findsNothing);
    expect(find.byType(LabResultsCard), findsNothing);
    expect(find.byType(LabResultsNonNumericList), findsOneWidget);
  });

  testWidgets(
    'period filter re-filters chart points while cards keep unfiltered value',
    (tester) async {
      final chart = _FakeTrendChart();
      final notifier = _FakeLabResultsNotifier(
        _loaded(_tMixed, selected: 'lr_0001'),
      );
      await tester.pumpWidget(_buildScreen(notifier: notifier, chart: chart));
      await tester.pump();

      expect(chart.rendered.last.points.length, 3);

      await tester.tap(
        find.descendant(
          of: find.byType(LabResultsPeriodFilter),
          matching: find.text('6 months'),
        ),
      );
      await tester.pump();

      expect(notifier.state, isA<LabResultsLoaded>());
      expect((notifier.state as LabResultsLoaded).period, Period.sixMonths);
      expect(chart.rendered.last.points.length, 2);
      expect(
        chart.rendered.last.points.map((p) => p.value),
        isNot(contains(12.1)),
      );

      expect(
        find.text('16.8'),
        findsOneWidget,
        reason: 'the card must keep the latest UNFILTERED value and chip',
      );
      expect(find.text('Normal'), findsOneWidget);
    },
  );

  testWidgets('chart tooltip lines carry date, value+unit, range and status', (
    tester,
  ) async {
    final chart = _FakeTrendChart();
    await tester.pumpWidget(
      _buildScreen(
        state: _loaded(_tMixed, selected: 'lr_0001'),
        chart: chart,
      ),
    );
    await tester.pump();

    expect(chart.rendered, isNotEmpty);
    final tooltip = chart.rendered.last.tooltipLines.join('\n');
    expect(tooltip, isNotEmpty);
    expect(tooltip, contains('2026'));
    expect(tooltip, contains('16.8'));
    expect(tooltip, contains('g/dL'));
    expect(tooltip, contains('13'));
    expect(tooltip, contains('17'));
    expect(tooltip, contains('Normal'));
  });

  testWidgets('empty list shows empty state and retry that calls load', (
    tester,
  ) async {
    final notifier = _FakeLabResultsNotifier(
      _loaded(const <LabResultEntity>[], selected: null),
    );
    await tester.pumpWidget(_buildScreen(notifier: notifier));
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No lab results.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(notifier.loadCallCount, greaterThan(0));
  });

  testWidgets(
    'failure shows localized snackbar + error state and does NOT reset',
    (tester) async {
      final notifier = _FakeLabResultsNotifier(const LabResultsInitial());
      await tester.pumpWidget(_buildScreen(notifier: notifier));
      await tester.pump();
      final initialLoads = notifier.loadCallCount;

      notifier.state = const LabResultsFailure(error: NetworkError());
      await tester.pump();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('No internet connection'), findsWidgets);
      expect(
        notifier.resetCallCount,
        0,
        reason:
            'failure must NOT reset to Initial (would create an infinite '
            'load→fail→reset→load loop offline)',
      );
      expect(
        notifier.loadCallCount,
        initialLoads,
        reason: 'no automatic reload after failure',
      );

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets('refresh failure keeps the list and shows an error snackbar', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        labResultsProvider.overrideWith(
          () => _FakeLabResultsNotifier(_loaded(_tMixed, selected: 'lr_0001')),
        ),
        trendChartProvider.overrideWithValue(_FakeTrendChart()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_buildScreen(container: container));
    await tester.pump();

    expect(find.byType(LabResultsCard), findsNWidgets(3));

    container
        .read(labResultsRefreshErrorProvider.notifier)
        .set(const NetworkError());
    await tester.pump();

    expect(
      find.byType(LabResultsCard),
      findsNWidgets(3),
      reason: 'a failed refresh keeps the last loaded results visible',
    );
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('No internet connection'), findsWidgets);
    expect(find.byType(ErrorState), findsNothing);
  });

  testWidgets('wraps the content in a RefreshIndicator and triggers refresh', (
    tester,
  ) async {
    final notifier = _FakeLabResultsNotifier(
      _loaded(_tMixed, selected: 'lr_0001'),
    );
    await tester.pumpWidget(_buildScreen(notifier: notifier));
    await tester.pump();

    expect(find.byType(RefreshIndicator), findsOneWidget);
    final indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    expect(indicator.semanticsLabel, 'Refresh results');

    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 300),
      1000,
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(notifier.refreshCallCount, greaterThan(0));
  });
}
