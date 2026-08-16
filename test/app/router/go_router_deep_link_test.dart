import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/app/di/auth/auth_observer_provider.dart';
import 'package:clean_architecture_sdd_harness/app/di/router/router_provider.dart';
import 'package:clean_architecture_sdd_harness/app/widgets/app_error_screen.dart';
import 'package:clean_architecture_sdd_harness/core/router/app_navigator_provider.dart';
import 'package:clean_architecture_sdd_harness/core/services/auth/i_authentication_observer.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/di/clinical_history_provider.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/repositories/i_clinical_history_repository.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';

class _FakeAuthObserver extends ChangeNotifier
    implements IAuthenticationObserver {
  bool _isAuthenticated = false;

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

class _FakeNavigator implements IAppNavigator {
  @override
  void go(AppRoute route, {Object? extra}) {}

  @override
  Future<void> push(AppRoute route, {Object? extra}) async {}
}

void main() {
  ProviderContainer createContainer(_FakeAuthObserver observer) {
    final container = ProviderContainer(
      overrides: [
        authenticationObserverProvider.overrideWith((ref) => observer),
        clinicalHistoryRepositoryProvider.overrideWith(
          (ref) => _FakeClinicalHistoryRepository(),
        ),
        appNavigatorProvider.overrideWith((ref) => _FakeNavigator()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget buildApp(ProviderContainer container) => UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: container.read(goRouterProvider),
    ),
  );

  testWidgets(
    'deep link target is preserved across the login bounce and restored after auth',
    (tester) async {
      final observer = _FakeAuthObserver();
      final container = createContainer(observer);
      final router = container.read(goRouterProvider);

      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      router.go(AppRoute.clinicalHistory.path);
      await tester.pumpAndSettle();

      expect(router.state.matchedLocation, AppRoute.login.path);
      expect(
        router.state.uri.queryParameters['from'],
        AppRoute.clinicalHistory.path,
      );

      observer.update(true);
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, AppRoute.clinicalHistory.path);
    },
  );

  testWidgets('unknown path renders AppErrorScreen (errorBuilder)', (
    tester,
  ) async {
    final observer = _FakeAuthObserver()..update(true);
    final container = createContainer(observer);
    final router = container.read(goRouterProvider);

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    router.go('/unknown');
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorScreen), findsOneWidget);
  });
}
