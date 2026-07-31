import 'package:clean_architecture_sdd_harness/app/di/network/dio_provider.dart';
import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_credential_store.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/handle_401_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';

class MockInternetService extends Mock implements InternetService {}

class MockCredentialStore extends Mock implements ICredentialStore {}

void main() {
  group('httpServiceProvider', () {
    test('provides a DioWrapper with ConnectionProfile injected', () {
      final container = ProviderContainer(overrides: [
        internetServiceProvider.overrideWithValue(MockInternetService()),
        handle401UseCaseProvider.overrideWith((ref) => Handle401UseCase(
          tokenStore: MockTokenStore(),
          connectivityChecker: MockConnectivityChecker(),
          credentialStore: MockCredentialStore(),
          repository: MockAuthRepository(),
        )),
      ]);

      final dioWrapper = container.read(httpServiceProvider);

      expect(dioWrapper, isA<DioWrapper>());

      container.dispose();
    });

    test('returns IDioWrapper interface', () {
      final container = ProviderContainer(overrides: [
        internetServiceProvider.overrideWithValue(MockInternetService()),
        handle401UseCaseProvider.overrideWith((ref) => Handle401UseCase(
          tokenStore: MockTokenStore(),
          connectivityChecker: MockConnectivityChecker(),
          credentialStore: MockCredentialStore(),
          repository: MockAuthRepository(),
        )),
      ]);

      final dio = container.read(httpServiceProvider);

      expect(dio, isA<IDioWrapper>());

      container.dispose();
    });
  });

  group('authDioProvider', () {
    test('returns IDioWrapper', () {
      final container = ProviderContainer(overrides: [
        internetServiceProvider.overrideWithValue(MockInternetService()),
        handle401UseCaseProvider.overrideWith((ref) => Handle401UseCase(
          tokenStore: MockTokenStore(),
          connectivityChecker: MockConnectivityChecker(),
          credentialStore: MockCredentialStore(),
          repository: MockAuthRepository(),
        )),
      ]);

      final dio = container.read(authDioProvider);

      expect(dio, isA<IDioWrapper>());

      container.dispose();
    });
  });

  group('dio_provider identity', () {
    test('authDioProvider and httpServiceProvider return DIFFERENT instances', () {
      final container = ProviderContainer(overrides: [
        internetServiceProvider.overrideWithValue(MockInternetService()),
        handle401UseCaseProvider.overrideWith((ref) => Handle401UseCase(
          tokenStore: MockTokenStore(),
          connectivityChecker: MockConnectivityChecker(),
          credentialStore: MockCredentialStore(),
          repository: MockAuthRepository(),
        )),
      ]);

      final dioWithout = container.read(authDioProvider);
      final dioWith = container.read(httpServiceProvider);

      expect(identical(dioWithout, dioWith), isFalse,
          reason: 'MUST be different instances to avoid interceptor contamination');

      container.dispose();
    });
  });
}
