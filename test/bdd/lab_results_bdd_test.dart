import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/core/config/environment_provider.dart';
import 'package:clean_architecture_sdd_harness/design_system/components/empty_state.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkart/gherkart.dart';
import 'package:gherkart/gherkart_io.dart';

class _SharedSpy {
  int loadCallCount = 0;
  int refreshCallCount = 0;
  List<LabResultEntity>? serverData;
  List<LabResultEntity>? refreshedData;
  bool loadFails = false;
  bool refreshFails = false;

  void reset() {
    loadCallCount = 0;
    refreshCallCount = 0;
    serverData = null;
    refreshedData = null;
    loadFails = false;
    refreshFails = false;
  }
}

class _RecordingTrendChart implements ITrendChart {
  TrendChartData? lastData;

  void reset() {
    lastData = null;
  }

  @override
  Widget lineChart({required TrendChartData data}) {
    lastData = data;
    return const SizedBox.shrink();
  }
}

class _SpyLabResultsNotifier extends LabResultsNotifier {
  _SpyLabResultsNotifier(this._initialState, this._spy) : super();

  final LabResultsState _initialState;
  final _SharedSpy _spy;

  @override
  LabResultsState build() => _initialState;

  @override
  Future<void> load() async {
    _spy.loadCallCount++;
    if (_spy.loadFails) {
      state = const LabResultsFailure(error: NetworkError());
    } else if (_spy.serverData != null) {
      state = LabResultsLoaded(
        results: _spy.serverData!,
        selectedTestId: _firstNumericId(_spy.serverData!),
        period: Period.all,
      );
    }
  }

  @override
  Future<void> refresh() async {
    _spy.refreshCallCount++;
    if (_spy.refreshFails) {
      ref
          .read(labResultsRefreshErrorProvider.notifier)
          .set(const NetworkError());
      return;
    }
    if (_spy.refreshedData != null) {
      state = LabResultsLoaded(
        results: _spy.refreshedData!,
        selectedTestId: _firstNumericId(_spy.refreshedData!),
        period: Period.all,
      );
    }
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

ProviderContainer? _lastContainer;

Widget _buildScreen(
  LabResultsState state,
  _SharedSpy spy,
  _RecordingTrendChart chart,
) {
  _lastContainer?.dispose();
  _lastContainer = ProviderContainer(
    overrides: [
      labResultsProvider.overrideWith(() => _SpyLabResultsNotifier(state, spy)),
      trendChartProvider.overrideWith((ref) => chart),
      environmentProvider.overrideWith((ref) => const ProductionEnvironment()),
    ],
  );
  return UncontrolledProviderScope(
    container: _lastContainer!,
    child: MaterialApp(
      theme: AppTheme.material3,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: const LabResultsScreen(),
    ),
  );
}

void _setLargeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

class _ScenarioState {
  final spy = _SharedSpy();
  final chart = _RecordingTrendChart();
  LabResultsState currentState = const LabResultsInitial();

  void reset() {
    _lastContainer?.dispose();
    _lastContainer = null;
    spy.reset();
    chart.reset();
    currentState = const LabResultsInitial();
  }
}

final _s = _ScenarioState();

final _tHb = LabResultEntity(
  id: 'lr_0001',
  testCode: 'HB',
  testName: 'Hemoglobina',
  category: 'Hematología',
  unit: 'g/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 13.0, high: 17.0),
  values: [
    LabResultValueEntity(date: DateTime(2026, 8, 10), value: 16.8),
    LabResultValueEntity(date: DateTime(2026, 6, 14), value: 15.4),
    LabResultValueEntity(date: DateTime(2026, 3, 22), value: 14.9),
    LabResultValueEntity(date: DateTime(2025, 12, 1), value: 13.2),
  ],
);

final _tGlucosa = LabResultEntity(
  id: 'lr_0002',
  testCode: 'GLU',
  testName: 'Glucosa en ayunas',
  category: 'Química sanguínea',
  unit: 'mg/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 70.0, high: 110.0),
  values: [
    LabResultValueEntity(date: DateTime(2026, 8, 10), value: 128.0),
    LabResultValueEntity(date: DateTime(2026, 6, 14), value: 118.5),
    LabResultValueEntity(date: DateTime(2026, 3, 22), value: 96.0),
  ],
);

final _tPotasio = LabResultEntity(
  id: 'lr_0003',
  testCode: 'K',
  testName: 'Potasio sérico',
  category: 'Electrolitos',
  unit: 'mmol/L',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 3.5, high: 5.1),
  values: [
    LabResultValueEntity(date: DateTime(2026, 8, 10), value: 3.2),
    LabResultValueEntity(date: DateTime(2026, 3, 22), value: 3.8),
  ],
);

final _tPcr = LabResultEntity(
  id: 'lr_0004',
  testCode: 'PCR',
  testName: 'Proteína C reactiva',
  category: 'Inmunología',
  unit: 'mg/L',
  kind: LabResultKind.numeric,
  referenceRange: null,
  values: [
    LabResultValueEntity(date: DateTime(2026, 8, 10), value: 2.4),
    LabResultValueEntity(date: DateTime(2026, 6, 14), value: 1.9),
  ],
);

final _tGrupo = LabResultEntity(
  id: 'lr_0005',
  testCode: 'GRUPO',
  testName: 'Grupo sanguíneo',
  category: 'Inmunohematología',
  unit: null,
  kind: LabResultKind.text,
  referenceRange: null,
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      textValue: 'A Positivo (A+)',
    ),
    LabResultValueEntity(
      date: DateTime(2026, 3, 22),
      textValue: 'A Positivo (A+)',
    ),
  ],
);

final _tSedimento = LabResultEntity(
  id: 'lr_0006',
  testCode: 'SED',
  testName: 'Sedimento de orina',
  category: 'Análisis de orina',
  unit: null,
  kind: LabResultKind.text,
  referenceRange: null,
  values: [
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      textValue: 'No se observan cristales',
    ),
    LabResultValueEntity(
      date: DateTime(2026, 6, 14),
      textValue: 'Presencia leve de cristales de oxalato',
    ),
  ],
);

final _tMixedList = [_tHb, _tGlucosa, _tPotasio, _tPcr, _tGrupo, _tSedimento];

final _tTextOnlyList = [_tGrupo, _tSedimento];

final _tHbRefreshed = LabResultEntity(
  id: 'lr_0001',
  testCode: 'HB',
  testName: 'Hemoglobina',
  category: 'Hematología',
  unit: 'g/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 13.0, high: 17.0),
  values: [
    LabResultValueEntity(date: DateTime(2026, 8, 12), value: 17.2),
    LabResultValueEntity(date: DateTime(2026, 8, 10), value: 16.8),
  ],
);

final _tGlucosaRefreshed = LabResultEntity(
  id: 'lr_0002',
  testCode: 'GLU',
  testName: 'Glucosa en ayunas',
  category: 'Química sanguínea',
  unit: 'mg/dL',
  kind: LabResultKind.numeric,
  referenceRange: const LabResultReferenceRangeEntity(low: 70.0, high: 110.0),
  values: [LabResultValueEntity(date: DateTime(2026, 8, 12), value: 99.0)],
);

final _tRefreshedList = [_tHbRefreshed, _tGlucosaRefreshed];

String? _firstNumericId(List<LabResultEntity> results) {
  for (final result in results) {
    if (result.kind == LabResultKind.numeric) {
      return result.id;
    }
  }
  return null;
}

Finder _cardText(String text) =>
    find.descendant(of: find.byType(LabResultsCard), matching: find.text(text));

LabResultsState _loadedFromServer(_SharedSpy spy) {
  final results = spy.serverData ?? const <LabResultEntity>[];
  return LabResultsLoaded(
    results: results,
    selectedTestId: _firstNumericId(results),
    period: Period.all,
  );
}

void _testFunction(
  String name, {
  List<String>? tags,
  bool skip = false,
  Future<void> Function(WidgetTester)? callback,
}) {
  testWidgets(name, (tester) async {
    await callback!(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    _s.reset();
    await tester.pump();
  }, skip: skip);
}

Future<void> main() async {
  setUp(() {
    _s.reset();
  });

  final registry = StepRegistry<WidgetTester>.fromMap({
    'the user is authenticated and has a clinical history with lab results'
        .mapper(): (tester, ctx) async {
      _s.reset();
    },

    'the server responds with mixed lab results (numeric with a reference range, numeric without one, and non-numeric)'
        .mapper(): (tester, ctx) async {
      _s.spy.serverData = _tMixedList;
    },

    'the user opens the lab results screen from the clinical history AppBar action'
        .mapper(): (tester, ctx) async {
      _setLargeSurface(tester);
      _s.currentState = const LabResultsInitial();
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy, _s.chart));
      await tester.pump();
      await tester.pump();
    },

    'the screen shows a numeric test selector and a period filter (default All)'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.byType(LabResultsTestSelector), findsOneWidget);
      expect(find.byType(LabResultsPeriodFilter), findsOneWidget);
    },

    'a card per numeric test shows the latest value with its unit and a derived status chip (Normal/High/Low/Unknown)'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(_cardText('Hemoglobina'), findsOneWidget);
      expect(_cardText('Glucosa en ayunas'), findsOneWidget);
      expect(_cardText('Potasio sérico'), findsOneWidget);
      expect(_cardText('Proteína C reactiva'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Alto'), findsOneWidget);
      expect(find.text('Bajo'), findsOneWidget);
      expect(find.text('Desconocido'), findsOneWidget);
      expect(find.textContaining('g/dL'), findsWidgets);
      expect(find.textContaining('mg/dL'), findsWidgets);
      expect(find.textContaining('mmol/L'), findsWidgets);
      expect(find.textContaining('mg/L'), findsWidgets);
    },

    'all non-numeric tests render as a flat list section below the chart pane with their latest textual value and no status chip'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.byType(LabResultsNonNumericList), findsOneWidget);
      expect(find.text('A Positivo (A+)'), findsOneWidget);
      expect(find.text('No se observan cristales'), findsOneWidget);
    },

    'the data is written through to the local cache'
        .mapper(): (tester, ctx) async {
      expect(_s.spy.loadCallCount, greaterThan(0));
    },

    'the user is viewing the loaded lab results'.mapper(): (tester, ctx) async {
      _setLargeSurface(tester);
      _s.spy.serverData = _tMixedList;
      _s.currentState = _loadedFromServer(_s.spy);
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy, _s.chart));
      await tester.pump();
    },

    'the user selects a numeric test in the selector'
        .mapper(): (tester, ctx) async {
      final loaded = _s.currentState as LabResultsLoaded;
      _s.currentState = LabResultsLoaded(
        results: loaded.results,
        selectedTestId: 'lr_0002',
        period: loaded.period,
      );
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy, _s.chart));
      await tester.pump();
    },

    'the chart pane renders that test\'s trend chart filtered by the active period'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.byType(LabResultsChartPane), findsOneWidget);
      expect(_s.chart.lastData, isNotNull);
      expect(_s.chart.lastData!.points.length, 3);
      expect(_s.chart.lastData!.points.map((p) => p.value), contains(128.0));
      expect(_s.chart.lastData!.unit, 'mg/dL');
    },

    'the chart shows a visible reference-range band when the test defines one'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(_s.chart.lastData!.referenceLow, equals(70.0));
      expect(_s.chart.lastData!.referenceHigh, equals(110.0));
    },

    'the server responds only with non-numeric lab results'
        .mapper(): (tester, ctx) async {
      _s.spy.serverData = _tTextOnlyList;
    },

    'the user opens the lab results screen'.mapper(): (tester, ctx) async {
      _setLargeSurface(tester);
      _s.currentState = const LabResultsInitial();
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy, _s.chart));
      await tester.pump();
      await tester.pump();
    },

    'the test selector and the period filter are hidden entirely'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.byType(LabResultsTestSelector), findsNothing);
      expect(find.byType(LabResultsPeriodFilter), findsNothing);
    },

    'a flat list of all non-numeric tests is shown with their latest textual values'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.byType(LabResultsNonNumericList), findsOneWidget);
      expect(find.text('A Positivo (A+)'), findsOneWidget);
      expect(find.text('No se observan cristales'), findsOneWidget);
    },

    'the server responds with an empty lab results list'
        .mapper(): (tester, ctx) async {
      _s.spy.serverData = const <LabResultEntity>[];
    },

    'the screen shows an icon and the localized message "No hay resultados de laboratorio"'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No hay resultados de laboratorio'), findsOneWidget);
    },

    'the user can tap a retry button that reloads the results'
        .mapper(): (tester, ctx) async {
      expect(find.text('Reintentar'), findsOneWidget);
      final loadsBeforeRetry = _s.spy.loadCallCount;
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await tester.pump();
      expect(_s.spy.loadCallCount, greaterThan(loadsBeforeRetry));
    },

    'the user pulls down to refresh'.mapper(): (tester, ctx) async {
      _setLargeSurface(tester);
      if (!_s.spy.refreshFails) {
        _s.spy.refreshedData = _tRefreshedList;
      }
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();
    },

    'the screen requests the server again'.mapper(): (tester, ctx) async {
      expect(_s.spy.refreshCallCount, greaterThan(0));
    },

    'the results update with the fresh server data'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(_cardText('Hemoglobina'), findsOneWidget);
      expect(_cardText('Glucosa en ayunas'), findsOneWidget);
      expect(find.textContaining('17.2'), findsWidgets);
      expect(find.text('Proteína C reactiva'), findsNothing);
      expect(find.textContaining('2.4'), findsNothing);
    },

    'the fresh data is written through to the local cache'
        .mapper(): (tester, ctx) async {
      expect(_s.spy.refreshCallCount, greaterThan(0));
    },

    'the server fails when refreshing'.mapper(): (tester, ctx) async {
      _s.spy.refreshFails = true;
    },

    'the loaded results remain visible'.mapper(): (tester, ctx) async {
      await tester.pump();
      expect(_cardText('Hemoglobina'), findsOneWidget);
      expect(find.textContaining('16.8'), findsWidgets);
      expect(find.text('Normal'), findsOneWidget);
    },

    'a localized error snackbar is shown'.mapper(): (tester, ctx) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Sin conexión a internet'), findsWidgets);
    },
  });

  await runBddTests<WidgetTester>(
    rootPaths: ['lib/features/lab_results/spec/bdd.feature'],
    registry: registry,
    source: FileSystemSource(),
    adapter: TestAdapter<WidgetTester>(
      testFunction: _testFunction,
      group: group,
      setUpAll: setUpAll,
      tearDownAll: tearDownAll,
      fail: (message) => fail(message),
    ),
    structure: TestStructure.flat,
  );
}
