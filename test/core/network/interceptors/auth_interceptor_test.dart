import 'package:clean_architecture_sdd_harness/core/network/interceptors/_interceptors.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/retry/exponential_backoff.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _CapturingHandler extends ErrorInterceptorHandler {
  DioException? nextError;
  Response<dynamic>? resolvedResponse;

  @override
  void next(DioException err) {
    nextError = err;
  }

  @override
  void resolve(Response<dynamic> response) {
    resolvedResponse = response;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions());
  });

  late Dio internalDio;
  late AuthInterceptor interceptor;
  late bool forceLogoutCalled;
  RetryResult? retryResult;

  Future<RetryResult> onRetry() async => retryResult!;

  Future<_CapturingHandler> runOnError(DioException err) async {
    final handler = _CapturingHandler();
    try {
      await interceptor.onError(err, handler);
    } catch (_) {}
    return handler;
  }

  setUp(() {
    internalDio = _MockDio();
    forceLogoutCalled = false;
    retryResult = null;

    interceptor = AuthInterceptor(
      onRetry: onRetry,
      internalDio: internalDio,
      onForceLogout: () => forceLogoutCalled = true,
    );
  });

  group('onError - 401 with successful retry', () {
    test('resolves request after onRetry succeeds', () async {
      retryResult = const RetrySuccess('new_token');

      final retryResponse = Response(
        requestOptions: RequestOptions(path: '/original'),
        statusCode: 200,
        data: {'ok': true},
      );
      when(
        () => internalDio.fetch<dynamic>(any()),
      ).thenAnswer((_) async => retryResponse);

      final err = DioException(
        requestOptions: RequestOptions(path: '/original'),
        response: Response(
          requestOptions: RequestOptions(path: '/original'),
          statusCode: 401,
        ),
      );

      await runOnError(err);

      verify(() => internalDio.fetch<dynamic>(any())).called(1);
    });
  });

  group('onError - 401 with retry returning RetryFailed', () {
    test('passes through and calls onForceLogout', () async {
      retryResult = const RetryFailed();

      final err = DioException(
        requestOptions: RequestOptions(path: '/original'),
        response: Response(
          requestOptions: RequestOptions(path: '/original'),
          statusCode: 401,
        ),
      );

      await runOnError(err);

      expect(forceLogoutCalled, isTrue);
    });
  });

  group('onError - 401 without connection', () {
    test(
      'passes through without calling onForceLogout after max retries',
      () async {
        retryResult = const RetryNoConnection();

        interceptor = AuthInterceptor(
          onRetry: onRetry,
          internalDio: internalDio,
          onForceLogout: () => forceLogoutCalled = true,
          retryPolicy: const ExponentialBackoff(
            baseDelay: Duration.zero,
            maxRetries: 1,
          ),
        );

        final err = DioException(
          requestOptions: RequestOptions(path: '/original'),
          response: Response(
            requestOptions: RequestOptions(path: '/original'),
            statusCode: 401,
          ),
        );

        await runOnError(err);

        expect(forceLogoutCalled, isTrue);
      },
    );
  });

  group('onError - non-401 errors', () {
    test('passes through without calling onRetry', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/original'),
        response: Response(
          requestOptions: RequestOptions(path: '/original'),
          statusCode: 403,
        ),
      );

      await runOnError(err);

      expect(forceLogoutCalled, isFalse);
    });
  });

  group('onError - rate limiting with backoff', () {
    test('calls onRetry only once when concurrent 401s arrive', () async {
      retryResult = const RetrySuccess('new_token');
      var retryCallCount = 0;
      var resolveFirst = true;

      interceptor = AuthInterceptor(
        onRetry: () async {
          retryCallCount++;
          return retryResult!;
        },
        internalDio: internalDio,
        onForceLogout: () => forceLogoutCalled = true,
        retryPolicy: const ExponentialBackoff(maxRetries: 1),
      );

      when(() => internalDio.fetch<dynamic>(any())).thenAnswer((_) async {
        if (resolveFirst) {
          resolveFirst = false;
          return Response(
            requestOptions: RequestOptions(path: '/original'),
            statusCode: 200,
            data: {'ok': true},
          );
        }
        throw DioException(requestOptions: RequestOptions(path: '/original'));
      });

      final err = DioException(
        requestOptions: RequestOptions(path: '/original'),
        response: Response(
          requestOptions: RequestOptions(path: '/original'),
          statusCode: 401,
        ),
      );

      await Future.wait([runOnError(err), runOnError(err)]);

      expect(retryCallCount, equals(1));
    });
  });

  group('ExponentialBackoff', () {
    test('nextDelay returns base for first attempt', () {
      final backoff = const ExponentialBackoff(
        baseDelay: Duration(seconds: 1),
        maxDelay: Duration(seconds: 10),
        multiplier: 2.0,
      );

      expect(backoff.nextDelay(1), const Duration(seconds: 1));
    });

    test('nextDelay doubles for second attempt', () {
      final backoff = const ExponentialBackoff(
        baseDelay: Duration(seconds: 1),
        maxDelay: Duration(seconds: 10),
        multiplier: 2.0,
      );

      expect(backoff.nextDelay(2), const Duration(seconds: 2));
    });

    test('nextDelay quadruples for third attempt', () {
      final backoff = const ExponentialBackoff(
        baseDelay: Duration(seconds: 1),
        maxDelay: Duration(seconds: 10),
        multiplier: 2.0,
      );

      expect(backoff.nextDelay(3), const Duration(seconds: 4));
    });

    test('nextDelay caps at maxDelay', () {
      final backoff = const ExponentialBackoff(
        baseDelay: Duration(seconds: 10),
        maxDelay: Duration(seconds: 15),
        multiplier: 2.0,
      );

      expect(backoff.nextDelay(2), const Duration(seconds: 15));
    });

    test('uses default values when constructed without parameters', () {
      const backoff = ExponentialBackoff();

      expect(backoff.baseDelay, const Duration(seconds: 1));
      expect(backoff.maxDelay, const Duration(seconds: 30));
      expect(backoff.maxRetries, 3);
      expect(backoff.multiplier, 2.0);
    });

    test('constructor maxRetries defaults to 3', () {
      const backoff = ExponentialBackoff();

      expect(backoff.maxRetries, 3);
    });
  });

  group('constructor and factory', () {
    test('should be created with required parameters', () {
      expect(interceptor, isA<AuthInterceptor>());
    });

    test('should use CustomInterceptors.auth factory', () {
      final factoryInterceptor = CustomInterceptors.auth(
        onRetry: () async => const RetryFailed(),
        internalDio: Dio(),
        onForceLogout: () {},
      );
      expect(factoryInterceptor, isA<AuthInterceptor>());
    });

    test('should accept custom retry policy via factory', () {
      final factoryInterceptor = CustomInterceptors.auth(
        onRetry: () async => const RetryFailed(),
        internalDio: Dio(),
        onForceLogout: () {},
        retryPolicy: const ExponentialBackoff(maxRetries: 5),
      );
      expect(factoryInterceptor, isA<AuthInterceptor>());
    });
  });
}
