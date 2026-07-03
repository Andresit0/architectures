import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/shared/interceptors/_interceptors.lib.dart';

class _MockDio extends Mock implements Dio {}

/// Handler that captures next() calls without propagating errors
class _CapturingHandler extends ErrorInterceptorHandler {
  DioException? nextError;
  Response? resolvedResponse;

  @override
  void next(DioException err) {
    nextError = err;
  }

  @override
  void resolve(Response response) {
    resolvedResponse = response;
  }
}

void main() {
  const loginUri = 'http://localhost:5111/user/login';
  const refreshUri = 'http://localhost:5111/user/refreshtoken';

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  late Dio internalDio;
  late String? storedToken;
  late String? savedToken;
  late ({String email, String passwordHash})? storedCredentials;
  late bool forceLogoutCalled;
  late AuthInterceptor interceptor;
  late bool connected;
  Future<bool> checkConnectivity() async => connected;

  /// Runs onError and returns the handler to inspect next/resolve state
  Future<_CapturingHandler> runOnError(DioException err) async {
    final handler = _CapturingHandler();
    try {
      await interceptor.onError(err, handler);
    } catch (_) {
      // handler.next() may also throw in some Dio versions
    }
    return handler;
  }

  setUp(() {
    internalDio = _MockDio();
    storedToken = null;
    savedToken = null;
    storedCredentials = null;
    forceLogoutCalled = false;
    AuthInterceptor.onForceLogout = null;
    connected = true;

    interceptor = AuthInterceptor(
      readToken: () async => storedToken,
      saveToken: (t) async => savedToken = t,
      readCredentials: () async => storedCredentials,
      internalDio: internalDio,
      loginUri: Uri.parse(loginUri),
      refreshUri: Uri.parse(refreshUri),
      checkConnectivity: checkConnectivity,
    );
  });

  group('onRequest', () {
    test('adds Bearer token header when token exists', () async {
      storedToken = 'my_token';
      final options = RequestOptions(path: '/test');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer my_token');
    });

    test('does not add Authorization header when token is null', () async {
      storedToken = null;
      final options = RequestOptions(path: '/test');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('does not add Authorization header when token is empty', () async {
      storedToken = '';
      final options = RequestOptions(path: '/test');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('onError — 401 with successful refresh', () {
    test('resolves request after token refresh succeeds', () async {
      storedToken = 'expired_token';

      final refreshResponse = Response(
        requestOptions: RequestOptions(path: refreshUri),
        statusCode: 200,
        data: {
          'token': {
            'key': 'new_token',
            'type': 'Bearer',
            'expires_in_hours': 24,
            'expiration_date': null,
          }
        },
      );
      when(() => internalDio.postUri(
        any(),
        options: any(named: 'options'),
      )).thenAnswer((_) async => refreshResponse);

      final retryResponse = Response(
        requestOptions: RequestOptions(path: '/original'),
        statusCode: 200,
        data: {'ok': true},
      );
      when(() => internalDio.fetch(any())).thenAnswer((_) async => retryResponse);

      final err = DioException(
        requestOptions: RequestOptions(path: '/original'),
        response: Response(
          requestOptions: RequestOptions(path: '/original'),
          statusCode: 401,
        ),
      );

      await runOnError(err);

      expect(savedToken, 'new_token');
    });
  });

  group('onError — 401 with refresh transport error', () {
    test('passes through when refresh fails with transport error', () async {
      storedToken = 'expired_token';

      when(() => internalDio.postUri(
        any(),
        options: any(named: 'options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: refreshUri),
        type: DioExceptionType.connectionTimeout,
      ));

      final err = DioException(
        requestOptions: RequestOptions(path: '/original'),
        response: Response(
          requestOptions: RequestOptions(path: '/original'),
          statusCode: 401,
        ),
      );

      await runOnError(err);

      expect(savedToken, isNull);
    });
  });

  group('onError — 401 with refresh HTTP error, re-login succeeds', () {
    test('resolves request after re-login succeeds', () async {
      storedToken = 'expired_token';
      storedCredentials = (email: 'test@test.com', passwordHash: 'hash');

      // Refresh returns HTTP error (non-200)
      when(() => internalDio.postUri(
        any(),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: refreshUri),
        statusCode: 401,
      ));

      // Re-login succeeds
      final loginResponse = Response(
        requestOptions: RequestOptions(path: loginUri),
        statusCode: 200,
        data: {
          'token': {
            'key': 'relogin_token',
            'type': 'Bearer',
            'expires_in_hours': 24,
            'expiration_date': null,
          }
        },
      );
      when(() => internalDio.postUri(
        any(),
        data: any(named: 'data'),
      )).thenAnswer((_) async => loginResponse);

      final retryResponse = Response(
        requestOptions: RequestOptions(path: '/original'),
        statusCode: 200,
        data: {'ok': true},
      );
      when(() => internalDio.fetch(any())).thenAnswer((_) async => retryResponse);

      final err = DioException(
        requestOptions: RequestOptions(path: '/original'),
        response: Response(
          requestOptions: RequestOptions(path: '/original'),
          statusCode: 401,
        ),
      );

      await runOnError(err);

      expect(savedToken, 'relogin_token');
    });
  });

  group('onError — forced logout scenarios', () {
    test('calls onForceLogout when no stored credentials', () async {
      storedToken = 'expired_token';
      storedCredentials = null;
      AuthInterceptor.onForceLogout = () => forceLogoutCalled = true;

      when(() => internalDio.postUri(
        any(),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: refreshUri),
        statusCode: 401,
      ));

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

    test('calls onForceLogout when re-login fails with HTTP error', () async {
      storedToken = 'expired_token';
      storedCredentials = (email: 'test@test.com', passwordHash: 'hash');
      AuthInterceptor.onForceLogout = () => forceLogoutCalled = true;

      // Refresh fails
      when(() => internalDio.postUri(
        any(),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: refreshUri),
        statusCode: 401,
      ));

      // Re-login fails with HTTP error
      when(() => internalDio.postUri(
        any(),
        data: any(named: 'data'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: loginUri),
        statusCode: 401,
      ));

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

    test('does NOT force logout when re-login fails with transport error', () async {
      storedToken = 'expired_token';
      storedCredentials = (email: 'test@test.com', passwordHash: 'hash');
      AuthInterceptor.onForceLogout = () => forceLogoutCalled = true;

      // Refresh fails with HTTP error
      when(() => internalDio.postUri(
        any(),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: refreshUri),
        statusCode: 401,
      ));

      // Re-login fails with transport error (no response)
      when(() => internalDio.postUri(
        any(),
        data: any(named: 'data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: loginUri),
        type: DioExceptionType.connectionTimeout,
      ));

      final err = DioException(
        requestOptions: RequestOptions(path: '/original'),
        response: Response(
          requestOptions: RequestOptions(path: '/original'),
          statusCode: 401,
        ),
      );

      await runOnError(err);

      expect(forceLogoutCalled, isFalse);
    });

    test('does NOT attempt refresh when offline (explicit connectivity check)', () async {
      storedToken = 'expired_token';
      storedCredentials = null;
      AuthInterceptor.onForceLogout = () => forceLogoutCalled = true;
      connected = false;

      final err = DioException(
        requestOptions: RequestOptions(path: '/original'),
        response: Response(
          requestOptions: RequestOptions(path: '/original'),
          statusCode: 401,
        ),
      );

      final handler = await runOnError(err);

      verifyNever(() => internalDio.postUri(any(), options: any(named: 'options')));
      expect(forceLogoutCalled, isFalse);
      expect(handler.nextError, isNotNull);
    });
  });

  group('constructor and factory', () {
    test('should be created with required parameters', () {
      expect(interceptor, isA<AuthInterceptor>());
    });

    test('should use CustomInterceptors.auth factory', () {
      final factoryInterceptor = CustomInterceptors.auth(
        readToken: () async => null,
        saveToken: (_) async {},
        readCredentials: () async => null,
        internalDio: Dio(),
        loginUri: Uri.parse(loginUri),
        refreshUri: Uri.parse(refreshUri),
        checkConnectivity: () async => true,
      );
      expect(factoryInterceptor, isA<AuthInterceptor>());
    });
  });
}