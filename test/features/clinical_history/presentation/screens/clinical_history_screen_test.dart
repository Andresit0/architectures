import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/core/router/app_navigator_provider.dart';
import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_theme.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_refresh_error_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/notifiers/clinical_history_state.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/screens/clinical_history_screen.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/widgets/clinical_history_card.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';

class _FakeNavigator implements IAppNavigator {
  AppRoute? lastGoRoute;

  @override
  void go(AppRoute route, {Object? extra}) {
    lastGoRoute = route;
  }

  @override
  Future<void> push(AppRoute route, {Object? extra}) async {
    lastGoRoute = route;
  }
}

class _FakeClinicalHistoryNotifier extends ClinicalHistoryNotifier {
  _FakeClinicalHistoryNotifier(this._initial) : super();

  final ClinicalHistoryState _initial;
  int loadCallCount = 0;
  int refreshCallCount = 0;
  int resetCallCount = 0;

  @override
  ClinicalHistoryState build() => _initial;

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
    state = const ClinicalHistoryInitial();
  }
}

const _tService1 = ClinicalHistoryServiceEntity(
  code: 'GEN',
  name: 'General Medicine',
  category: 'consultation',
);
const _tFacility1 = ClinicalHistoryFacilityEntity(
  id: 'FAC-001',
  name: 'Central Medical Center',
  city: 'Quito',
);
const _tEntity1 = ClinicalHistoryEntity(
  id: 'ch1',
  encounterNumber: 'ENC-001',
  service: _tService1,
  facility: _tFacility1,
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

Widget _buildScreen({
  ClinicalHistoryState state = const ClinicalHistoryInitial(),
  _FakeClinicalHistoryNotifier? notifier,
  Future<void> Function()? onLogout,
  ProviderContainer? container,
}) {
  final fake = notifier ?? _FakeClinicalHistoryNotifier(state);
  final effectiveContainer =
      container ??
      ProviderContainer(
        overrides: [clinicalHistoryProvider.overrideWith(() => fake)],
      );
  return UncontrolledProviderScope(
    container: effectiveContainer,
    child: MaterialApp(
      theme: AppTheme.material3,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ClinicalHistoryScreen(onLogout: onLogout),
    ),
  );
}

void main() {
  testWidgets('shows skeleton list when state is loading', (tester) async {
    await tester.pumpWidget(
      _buildScreen(state: const ClinicalHistoryLoading()),
    );
    await tester.pump();

    expect(find.byType(SkeletonList), findsOneWidget);
  });

  testWidgets('shows a card per encounter with header count when loaded', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen(state: ClinicalHistoryLoaded(_tList)));
    await tester.pump();

    expect(find.byType(ClinicalHistoryCard), findsNWidgets(2));
    expect(find.text('2 records'), findsOneWidget);
    expect(find.text('General Medicine'), findsOneWidget);
    expect(find.text('Pediatrics'), findsOneWidget);
    expect(find.text('Central Medical Center'), findsOneWidget);
    expect(find.text('Quito'), findsOneWidget);
    expect(find.text('North Side Clinic'), findsOneWidget);
    expect(find.text('Guayaquil'), findsOneWidget);
    expect(find.text('Jan 15, 2026'), findsOneWidget);
    expect(find.text('Feb 1, 2026'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('shows empty state message and retry button that calls load', (
    tester,
  ) async {
    final notifier = _FakeClinicalHistoryNotifier(
      const ClinicalHistoryLoaded(<ClinicalHistoryEntity>[]),
    );
    await tester.pumpWidget(_buildScreen(notifier: notifier));
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No clinical history records yet.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(notifier.loadCallCount, greaterThan(0));
  });

  testWidgets(
    'shows localized error snackbar + error state and does NOT reset',
    (tester) async {
      final notifier = _FakeClinicalHistoryNotifier(
        const ClinicalHistoryInitial(),
      );
      await tester.pumpWidget(_buildScreen(notifier: notifier));
      await tester.pump();
      final initialLoads = notifier.loadCallCount;

      notifier.state = const ClinicalHistoryFailure(NetworkError());
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

  testWidgets('error state shows a retry button that calls load', (
    tester,
  ) async {
    final notifier = _FakeClinicalHistoryNotifier(
      const ClinicalHistoryFailure(NetworkError()),
    );
    await tester.pumpWidget(_buildScreen(notifier: notifier));
    await tester.pump();

    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(notifier.loadCallCount, greaterThan(0));
  });

  testWidgets('refresh failure keeps the list and shows an error snackbar', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        clinicalHistoryProvider.overrideWith(
          () => _FakeClinicalHistoryNotifier(ClinicalHistoryLoaded(_tList)),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_buildScreen(container: container));
    await tester.pump();

    expect(find.byType(ClinicalHistoryCard), findsNWidgets(2));

    container
        .read(clinicalHistoryRefreshErrorProvider.notifier)
        .set(const NetworkError());
    await tester.pump();

    expect(
      find.byType(ClinicalHistoryCard),
      findsNWidgets(2),
      reason: 'a failed refresh keeps the last loaded list visible',
    );
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('No internet connection'), findsWidgets);
    expect(find.byType(ErrorState), findsNothing);
  });

  testWidgets('wraps the list in a RefreshIndicator and triggers refresh', (
    tester,
  ) async {
    final notifier = _FakeClinicalHistoryNotifier(
      ClinicalHistoryLoaded(_tList),
    );
    await tester.pumpWidget(_buildScreen(notifier: notifier));
    await tester.pump();

    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(notifier.refreshCallCount, greaterThan(0));
  });

  testWidgets('appbar shows clinical history title and logout calls onLogout', (
    tester,
  ) async {
    var logoutCalled = false;
    await tester.pumpWidget(
      _buildScreen(
        state: ClinicalHistoryLoaded(_tList),
        onLogout: () async => logoutCalled = true,
      ),
    );
    await tester.pump();

    expect(find.text('Clinical History'), findsOneWidget);
    expect(find.byTooltip('Logout'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();

    expect(logoutCalled, isTrue);
  });

  testWidgets('appbar hides logout button when onLogout is null', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen(state: ClinicalHistoryLoaded(_tList)));
    await tester.pump();

    expect(find.byTooltip('Logout'), findsNothing);
  });

  testWidgets('appbar Lab Results action navigates via IAppNavigator', (
    tester,
  ) async {
    final navigator = _FakeNavigator();
    final container = ProviderContainer(
      overrides: [
        clinicalHistoryProvider.overrideWith(
          () => _FakeClinicalHistoryNotifier(ClinicalHistoryLoaded(_tList)),
        ),
        appNavigatorProvider.overrideWith((ref) => navigator),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildScreen(container: container));
    await tester.pump();

    expect(find.byTooltip('Lab Results'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.biotech_outlined));
    await tester.pump();

    expect(navigator.lastGoRoute, AppRoute.labResults);
  });
}
