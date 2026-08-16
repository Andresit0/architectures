import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetService extends Mock implements InternetService {}

class _FakeAuthInterceptor implements IAuthInterceptorProvider {
  int setupCalls = 0;
  IDioWrapper? lastDio;

  @override
  void setupAuthInterceptor(IDioWrapper dioWrapper) {
    setupCalls++;
    lastDio = dioWrapper;
  }
}

void main() {
  group('httpServiceProvider', () {
    test('provides a DioWrapper with ConnectionProfile injected', () {
      final container = ProviderContainer(
        overrides: [
          internetServiceProvider.overrideWithValue(MockInternetService()),
          authInterceptorProvider.overrideWithValue(_FakeAuthInterceptor()),
        ],
      );

      final dioWrapper = container.read(httpServiceProvider);

      expect(dioWrapper, isA<DioWrapper>());

      container.dispose();
    });

    test('returns IDioWrapper interface', () {
      final container = ProviderContainer(
        overrides: [
          internetServiceProvider.overrideWithValue(MockInternetService()),
          authInterceptorProvider.overrideWithValue(_FakeAuthInterceptor()),
        ],
      );

      final dio = container.read(httpServiceProvider);

      expect(dio, isA<IDioWrapper>());

      container.dispose();
    });
  });

  group('authDioProvider', () {
    test('returns IDioWrapper', () {
      final container = ProviderContainer(
        overrides: [
          internetServiceProvider.overrideWithValue(MockInternetService()),
          authInterceptorProvider.overrideWithValue(_FakeAuthInterceptor()),
        ],
      );

      final dio = container.read(authDioProvider);

      expect(dio, isA<IDioWrapper>());

      container.dispose();
    });
  });

  group('dio_provider identity', () {
    test(
      'authDioProvider and httpServiceProvider return DIFFERENT instances',
      () {
        final container = ProviderContainer(
          overrides: [
            internetServiceProvider.overrideWithValue(MockInternetService()),
            authInterceptorProvider.overrideWithValue(_FakeAuthInterceptor()),
          ],
        );

        final dioWithout = container.read(authDioProvider);
        final dioWith = container.read(httpServiceProvider);

        expect(
          identical(dioWithout, dioWith),
          isFalse,
          reason:
              'MUST be different instances to avoid interceptor contamination',
        );

        container.dispose();
      },
    );
  });
}
