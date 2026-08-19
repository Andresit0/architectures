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
  group('DioProvider auth interceptor wiring', () {
    test(
      'httpServiceProvider wires authInterceptorProvider.setupAuthInterceptor',
      () {
        final fake = _FakeAuthInterceptor();
        final container = ProviderContainer(
          overrides: [
            internetServiceProvider.overrideWithValue(MockInternetService()),
            authInterceptorProvider.overrideWithValue(fake),
          ],
        );

        final dioWrapper = container.read(httpServiceProvider);

        expect(dioWrapper, isA<DioWrapper>());
        expect(
          fake.setupCalls,
          1,
          reason: 'httpServiceProvider MUST apply the auth interceptor once',
        );
        expect(identical(fake.lastDio, dioWrapper), isTrue);

        container.dispose();
      },
    );

    test('authDioProvider does NOT apply the auth interceptor', () {
      final fake = _FakeAuthInterceptor();
      final container = ProviderContainer(
        overrides: [
          internetServiceProvider.overrideWithValue(MockInternetService()),
          authInterceptorProvider.overrideWithValue(fake),
        ],
      );

      final dio = container.read(authDioProvider);

      expect(dio, isA<IDioWrapper>());
      expect(
        fake.setupCalls,
        0,
        reason:
            'authDioProvider MUST NOT apply the auth interceptor '
            '(no token exists yet during login/refresh)',
      );

      container.dispose();
    });
  });

  group('authInterceptorProvider seam', () {
    test(
      'throws SeamNotBoundException when not overridden (fail-fast seam)',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          () => container.read(authInterceptorProvider),
          throwsA(
            predicate(
              (e) =>
                  e.toString().contains(
                    'authInterceptorProvider must be overridden',
                  ) &&
                  !e.toString().contains('UnimplementedError'),
            ),
          ),
        );
      },
    );
  });
}
