import 'package:clean_architecture_sdd_harness/app/di/_providers.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_credential_store.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/handle_401_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';
import '../../helpers/mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetService extends Mock implements InternetService {}

class MockCredentialStore extends Mock implements ICredentialStore {}

void main() {
  group('Singleton providers', () {
    test('tokenStoreProvider returns the same instance on multiple reads', () {
      final container = ProviderContainer();
      final instance1 = container.read(tokenStoreProvider);
      final instance2 = container.read(tokenStoreProvider);
      expect(identical(instance1, instance2), isTrue);
      container.dispose();
    });

    test('httpServiceProvider returns the same instance on multiple reads', () {
      final container = ProviderContainer(overrides: [
        internetServiceProvider.overrideWithValue(MockInternetService()),
        handle401UseCaseProvider.overrideWith((ref) => Handle401UseCase(
          tokenStore: MockTokenStore(),
          connectivityChecker: MockConnectivityChecker(),
          credentialStore: MockCredentialStore(),
          repository: MockAuthRepository(),
        )),
      ]);
      final instance1 = container.read(httpServiceProvider);
      final instance2 = container.read(httpServiceProvider);
      expect(identical(instance1, instance2), isTrue);
      container.dispose();
    });

    test('appDatabaseProvider returns the same instance on multiple reads', () {
      final container = ProviderContainer();
      final instance1 = container.read(appDatabaseProvider);
      final instance2 = container.read(appDatabaseProvider);
      expect(identical(instance1, instance2), isTrue);
      container.dispose();
    });

    test('authProvider returns the same notifier on multiple reads', () {
      final container = ProviderContainer();
      final notifier1 = container.read(authProvider.notifier);
      final notifier2 = container.read(authProvider.notifier);
      expect(identical(notifier1, notifier2), isTrue);
      container.dispose();
    });
  });
}
