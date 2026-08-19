import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetService extends Mock implements IInternetService {}

class _FailedToFetchError {
  @override
  String toString() => 'TypeError: Failed to fetch';
}

class _NetworkErrorMessage {
  @override
  String toString() => 'Network Error';
}

class _GenericError {
  @override
  String toString() => 'Some unexpected error';
}

class _DioThrowWithErrorInterceptor extends Interceptor {
  _DioThrowWithErrorInterceptor({required this.error});

  final Object? error;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    throw DioException(
      type: DioExceptionType.unknown,
      requestOptions: options,
      error: error,
    );
  }
}

void main() {
  late MockInternetService mockInternetService;

  setUp(() {
    mockInternetService = MockInternetService();
    when(() => mockInternetService.isConnected()).thenAnswer((_) async => true);
    when(
      () => mockInternetService.isServerReachable(),
    ).thenAnswer((_) async => true);
  });

  group('ErrorMapper.isBrowserNetworkFailure', () {
    test('returns true for TypeError: Failed to fetch', () {
      expect(
        const ErrorMapper().isBrowserNetworkFailure(
          DioException(
            type: DioExceptionType.unknown,
            requestOptions: RequestOptions(path: 'https://example.com'),
            error: _FailedToFetchError(),
          ),
        ),
        isTrue,
      );
    });

    test('returns true for Network Error message', () {
      expect(
        const ErrorMapper().isBrowserNetworkFailure(
          DioException(
            type: DioExceptionType.unknown,
            requestOptions: RequestOptions(path: 'https://example.com'),
            error: _NetworkErrorMessage(),
          ),
        ),
        isTrue,
      );
    });

    test('returns true for a raw TypeError', () {
      expect(
        const ErrorMapper().isBrowserNetworkFailure(
          DioException(
            type: DioExceptionType.unknown,
            requestOptions: RequestOptions(path: 'https://example.com'),
            error: TypeError(),
          ),
        ),
        isTrue,
      );
    });

    test('returns false when error is null', () {
      expect(
        const ErrorMapper().isBrowserNetworkFailure(
          DioException(
            type: DioExceptionType.unknown,
            requestOptions: RequestOptions(path: 'https://example.com'),
          ),
        ),
        isFalse,
      );
    });

    test('returns false for generic unknown errors', () {
      expect(
        const ErrorMapper().isBrowserNetworkFailure(
          DioException(
            type: DioExceptionType.unknown,
            requestOptions: RequestOptions(path: 'https://example.com'),
            error: _GenericError(),
          ),
        ),
        isFalse,
      );
    });

    test('returns false for non-unknown DioException types', () {
      expect(
        const ErrorMapper().isBrowserNetworkFailure(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: 'https://example.com'),
            error: _FailedToFetchError(),
          ),
        ),
        isFalse,
      );
    });
  });

  group('DioWrapper web/CORS conditional fix', () {
    test(
      'unknown type with TypeError: Failed to fetch throws NoConnectionException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        dio.interceptors.add(
          _DioThrowWithErrorInterceptor(error: _FailedToFetchError()),
        );

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<NoConnectionException>()),
        );
      },
    );

    test(
      'unknown type with Network Error message throws NoConnectionException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        dio.interceptors.add(
          _DioThrowWithErrorInterceptor(error: _NetworkErrorMessage()),
        );

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<NoConnectionException>()),
        );
      },
    );

    test(
      'unknown type with raw TypeError throws NoConnectionException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        dio.interceptors.add(_DioThrowWithErrorInterceptor(error: TypeError()));

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<NoConnectionException>()),
        );
      },
    );

    test(
      'unknown type without browser signature throws UnexpectedResponseException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        dio.interceptors.add(
          _DioThrowWithErrorInterceptor(error: _GenericError()),
        );

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<UnexpectedResponseException>()),
        );
      },
    );

    test(
      'unknown type with no error throws UnexpectedResponseException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        dio.interceptors.add(_DioThrowWithErrorInterceptor(error: null));

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<UnexpectedResponseException>()),
        );
      },
    );
  });
}
