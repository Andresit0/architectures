import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/app/di/auth/auth_observer_provider.dart';
import 'package:clean_architecture_sdd_harness/app/di/router/go_router_navigator.dart';
import 'package:clean_architecture_sdd_harness/app/di/router/router_overrides.dart';
import 'package:clean_architecture_sdd_harness/app/di/router/router_provider.dart';
import 'package:clean_architecture_sdd_harness/core/services/auth/i_authentication_observer.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/di/clinical_history_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/repositories/i_clinical_history_repository.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';

class _FakeAuthObserver extends ChangeNotifier
    implements IAuthenticationObserver {
  bool _isAuthenticated = true;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  void update(bool value) {
    if (value != _isAuthenticated) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }
}

class _FakeClinicalHistoryRepository implements IClinicalHistoryRepository {
  @override
  Future<Result<List<ClinicalHistoryEntity>>> loadClinicalHistories() async =>
      const Success(<ClinicalHistoryEntity>[]);

  @override
  Future<Result<List<ClinicalHistoryEntity>>>
  refreshClinicalHistories() async => const Success(<ClinicalHistoryEntity>[]);
}

void main() {
  group('appNavigatorProvider seam', () {
    test(
      'throws SeamNotBoundException when not overridden (fail-fast seam)',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          () => container.read(appNavigatorProvider),
          throwsA(
            predicate(
              (e) =>
                  e.toString().contains(
                    'appNavigatorProvider must be overridden',
                  ) &&
                  !e.toString().contains('UnimplementedError'),
            ),
          ),
        );
      },
    );

    test('routerOverrides binds the seam to GoRouterNavigator', () {
      final container = ProviderContainer(
        overrides: [
          ...routerOverrides(),
          authenticationObserverProvider.overrideWith(
            (ref) => _FakeAuthObserver(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final navigator = container.read(appNavigatorProvider);
      expect(navigator, isA<GoRouterNavigator>());
    });

    testWidgets('go navigates to the typed route path', (tester) async {
      final container = ProviderContainer(
        overrides: [
          ...routerOverrides(),
          authenticationObserverProvider.overrideWith(
            (ref) => _FakeAuthObserver(),
          ),
          clinicalHistoryRepositoryProvider.overrideWith(
            (ref) => _FakeClinicalHistoryRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final navigator = container.read(appNavigatorProvider);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: container.read(goRouterProvider),
          ),
        ),
      );
      await tester.pumpAndSettle();

      navigator.go(AppRoute.clinicalHistory);
      await tester.pumpAndSettle();
      expect(
        container.read(goRouterProvider).state.matchedLocation,
        AppRoute.clinicalHistory.path,
      );
    });

    testWidgets('push navigates to the typed route path', (tester) async {
      final container = ProviderContainer(
        overrides: [
          ...routerOverrides(),
          authenticationObserverProvider.overrideWith(
            (ref) => _FakeAuthObserver(),
          ),
          clinicalHistoryRepositoryProvider.overrideWith(
            (ref) => _FakeClinicalHistoryRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final navigator = container.read(appNavigatorProvider);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: container.read(goRouterProvider),
          ),
        ),
      );
      await tester.pumpAndSettle();

      navigator.push(AppRoute.clinicalHistory);
      await tester.pumpAndSettle();
      expect(
        container.read(goRouterProvider).state.matchedLocation,
        AppRoute.clinicalHistory.path,
      );
    });
  });
}
