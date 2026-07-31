import 'package:clean_architecture_sdd_harness/app/di/network/dio_provider.dart';
import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_credential_store.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/handle_401_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/di/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/mocks.dart';

class MockInternetService extends Mock implements InternetService {}

class MockCredentialStore extends Mock implements ICredentialStore {}

void main() {
  group('DioProvider auth interceptor wiring', () {
    test('httpServiceProvider correctly wires setupAuthInterceptor through provider chain', () {
      final container = ProviderContainer(overrides: [
        internetServiceProvider.overrideWithValue(MockInternetService()),
        handle401UseCaseProvider.overrideWith((ref) => Handle401UseCase(
          tokenStore: MockTokenStore(),
          connectivityChecker: MockConnectivityChecker(),
          credentialStore: MockCredentialStore(),
          repository: MockAuthRepository(),
          refreshTokenUseCase: RefreshTokenUseCase(repository: MockAuthRepository()),
        )),
      ]);

      final dioWrapper = container.read(httpServiceProvider);

      expect(dioWrapper, isA<DioWrapper>());

      container.dispose();
    });
  });
}
