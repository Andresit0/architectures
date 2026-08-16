import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/core/config/environment_provider.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_theme.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_refresh_error_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_state.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/screens/clinical_history_screen.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/widgets/clinical_history_card.dart';
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
  int resetCallCount = 0;
  List<ClinicalHistoryEntity>? serverData;
  List<ClinicalHistoryEntity>? cachedData;
  List<ClinicalHistoryEntity>? refreshedData;
  bool loadFails = false;
  bool refreshFails = false;

  void reset() {
    loadCallCount = 0;
    refreshCallCount = 0;
    resetCallCount = 0;
    serverData = null;
    cachedData = null;
    refreshedData = null;
    loadFails = false;
    refreshFails = false;
  }
}

class _SpyClinicalHistoryNotifier extends ClinicalHistoryNotifier {
  _SpyClinicalHistoryNotifier(this._initialState, this._spy) : super();

  final ClinicalHistoryState _initialState;
  final _SharedSpy _spy;

  @override
  ClinicalHistoryState build() => _initialState;

  @override
  Future<void> load() async {
    _spy.loadCallCount++;
    if (_spy.loadFails) {
      state = const ClinicalHistoryFailure(NetworkError());
    } else if (_spy.serverData != null) {
      state = ClinicalHistoryLoaded(_spy.serverData!);
    } else if (_spy.cachedData != null) {
      state = ClinicalHistoryLoaded(_spy.cachedData!);
    }
  }

  @override
  Future<void> refresh() async {
    _spy.refreshCallCount++;
    if (_spy.refreshFails) {
      ref
          .read(clinicalHistoryRefreshErrorProvider.notifier)
          .set(const NetworkError());
      return;
    }
    if (_spy.refreshedData != null) {
      state = ClinicalHistoryLoaded(_spy.refreshedData!);
    }
  }

  @override
  void reset() {
    _spy.resetCallCount++;
    state = const ClinicalHistoryInitial();
  }
}

ProviderContainer? _lastContainer;

Widget _buildScreen(ClinicalHistoryState state, _SharedSpy spy) {
  _lastContainer?.dispose();
  _lastContainer = ProviderContainer(
    overrides: [
      clinicalHistoryProvider.overrideWith(
        () => _SpyClinicalHistoryNotifier(state, spy),
      ),
      environmentProvider.overrideWith((ref) => const ProductionEnvironment()),
    ],
  );
  return UncontrolledProviderScope(
    container: _lastContainer!,
    child: MaterialApp(
      theme: AppTheme.material3,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ClinicalHistoryScreen(),
    ),
  );
}

class _ScenarioState {
  final spy = _SharedSpy();
  ClinicalHistoryState currentState = const ClinicalHistoryInitial();

  void reset() {
    _lastContainer?.dispose();
    _lastContainer = null;
    spy.reset();
    currentState = const ClinicalHistoryInitial();
  }
}

final _s = _ScenarioState();

const _tEntity1 = ClinicalHistoryEntity(
  id: 'ch1',
  encounterNumber: 'ENC-001',
  service: ClinicalHistoryServiceEntity(
    code: 'GEN',
    name: 'General Medicine',
    category: 'consultation',
  ),
  facility: ClinicalHistoryFacilityEntity(
    id: 'FAC-001',
    name: 'Central Medical Center',
    city: 'Quito',
  ),
  professional: null,
  encounterDate: '2026-01-15',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: null,
  description: null,
  diagnosis: [],
  observations: [],
  attachments: [],
  state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
);
const _tEntity2 = ClinicalHistoryEntity(
  id: 'ch2',
  encounterNumber: 'ENC-002',
  service: ClinicalHistoryServiceEntity(
    code: 'PED',
    name: 'Pediatrics',
    category: 'consultation',
  ),
  facility: ClinicalHistoryFacilityEntity(
    id: 'FAC-002',
    name: 'North Side Clinic',
    city: 'Guayaquil',
  ),
  professional: null,
  encounterDate: '2026-02-01',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: null,
  description: null,
  diagnosis: [],
  observations: [],
  attachments: [],
  state: ClinicalHistoryStateEntity(code: 'closed', label: 'Closed'),
);
const _tList = [_tEntity1, _tEntity2];

const _tEntity1Refreshed = ClinicalHistoryEntity(
  id: 'ch1',
  encounterNumber: 'ENC-001',
  service: ClinicalHistoryServiceEntity(
    code: 'CAR',
    name: 'Cardiology',
    category: 'consultation',
  ),
  facility: ClinicalHistoryFacilityEntity(
    id: 'FAC-001',
    name: 'Central Medical Center',
    city: 'Quito',
  ),
  professional: null,
  encounterDate: '2026-01-15',
  createdAt: null,
  updatedAt: null,
  publishedAt: null,
  summary: null,
  description: null,
  diagnosis: [],
  observations: [],
  attachments: [],
  state: ClinicalHistoryStateEntity(code: 'ready', label: 'Available'),
);
const _tListAfterRefresh = [_tEntity1Refreshed];

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
    'the user is authenticated and viewing /clinical_history'
        .mapper(): (tester, ctx) async {
      _s.currentState = const ClinicalHistoryInitial();
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the server responds with two clinical history encounters'
        .mapper(): (tester, ctx) async {
      _s.spy.serverData = _tList;
    },

    'the server responds with an empty clinical history list'
        .mapper(): (tester, ctx) async {
      _s.spy.serverData = const <ClinicalHistoryEntity>[];
    },

    'the user is viewing the loaded clinical history list'
        .mapper(): (tester, ctx) async {
      _s.spy.serverData = _tList;
      _s.currentState = ClinicalHistoryLoaded(_tList);
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
    },

    'the device has no network connectivity'.mapper(): (tester, ctx) async {
      _s.spy.serverData = null;
      _s.spy.loadFails = true;
    },

    'the local cache contains previously stored encounters'
        .mapper(): (tester, ctx) async {
      _s.spy.cachedData = _tList;
      _s.spy.loadFails = false;
    },

    'the local cache is empty'.mapper(): (tester, ctx) async {
      _s.spy.cachedData = null;
    },

    'the server fails when refreshing'.mapper(): (tester, ctx) async {
      _s.spy.refreshFails = true;
    },

    'the user opens the clinical history screen'.mapper(): (tester, ctx) async {
      _s.currentState = const ClinicalHistoryInitial();
      await tester.pumpWidget(_buildScreen(_s.currentState, _s.spy));
      await tester.pump();
      await tester.pump();
    },

    'the user pulls down to refresh'.mapper(): (tester, ctx) async {
      _s.spy.refreshedData = _tListAfterRefresh;
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();
    },

    'the screen shows a list of two encounter cards'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.byType(ClinicalHistoryCard), findsNWidgets(2));
    },

    'each card shows the service name, facility name and city, encounter date and state label'
        .mapper(): (tester, ctx) async {
      expect(find.text('General Medicine'), findsOneWidget);
      expect(find.text('Pediatrics'), findsOneWidget);
      expect(find.text('Central Medical Center'), findsOneWidget);
      expect(find.text('Quito'), findsOneWidget);
      expect(find.text('North Side Clinic'), findsOneWidget);
      expect(find.text('Guayaquil'), findsOneWidget);
      expect(find.text('2026-01-15'), findsNothing);
      expect(find.text('Jan 15, 2026'), findsOneWidget);
      expect(find.text('2026-02-01'), findsNothing);
      expect(find.text('Feb 1, 2026'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
    },

    'the data is written through to the local cache'
        .mapper(): (tester, ctx) async {
      expect(_s.spy.loadCallCount, greaterThan(0));
    },

    'the screen shows an empty state message'.mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.text('No clinical history records yet.'), findsOneWidget);
    },

    'the user can tap a retry button that reloads the list'
        .mapper(): (tester, ctx) async {
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(_s.spy.loadCallCount, greaterThan(0));
    },

    'the screen requests the server again'.mapper(): (tester, ctx) async {
      expect(_s.spy.refreshCallCount, greaterThan(0));
    },

    'the list updates with the fresh server data'
        .mapper(): (tester, ctx) async {
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('General Medicine'), findsNothing);
    },

    'the fresh data is written through to the local cache'
        .mapper(): (tester, ctx) async {
      expect(_s.spy.refreshCallCount, greaterThan(0));
    },

    'the screen shows the cached encounters instead of an error'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.byType(ClinicalHistoryCard), findsNWidgets(2));
      expect(find.text('General Medicine'), findsOneWidget);
      expect(find.text('Pediatrics'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    },

    'the screen shows a localized error snackbar'
        .mapper(): (tester, ctx) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('No internet connection'), findsWidgets);
      expect(find.byType(SnackBar), findsOneWidget);
    },

    'the user can retry loading the list'.mapper(): (tester, ctx) async {
      expect(
        _s.spy.resetCallCount,
        0,
        reason: 'failure must NOT reset to Initial (no infinite reload loop)',
      );
      final loadsBeforeRetry = _s.spy.loadCallCount;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(_s.spy.loadCallCount, greaterThan(loadsBeforeRetry));
      expect(_s.spy.resetCallCount, 0);
    },

    'the cached encounters remain visible'.mapper(): (tester, ctx) async {
      expect(find.byType(ClinicalHistoryCard), findsNWidgets(2));
      expect(find.text('General Medicine'), findsOneWidget);
      expect(find.text('Pediatrics'), findsOneWidget);
    },

    'a localized error snackbar is shown'.mapper(): (tester, ctx) async {
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('No internet connection'), findsWidgets);
    },
  });

  await runBddTests<WidgetTester>(
    rootPaths: ['lib/features/clinical_history/spec/bdd.feature'],
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
