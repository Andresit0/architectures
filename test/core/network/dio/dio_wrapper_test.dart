import 'dart:async';
import 'dart:typed_data';

import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetService extends Mock implements IInternetService {}

bool validateCert(Uint8List der, List<String> pinned) {
  final sha = sha256.convert(der);
  return pinned.contains(sha.toString());
}

void main() {
  late MockInternetService mockInternetService;

  setUp(() {
    mockInternetService = MockInternetService();
  });

  group('DioWrapper certificate pinning', () {
    test('IOHttpClientAdapter.validateCertificate is configured', () {
      final dio = Dio();
      DioWrapper(mockInternetService, dio);

      final adapter = dio.httpClientAdapter;
      expect(adapter, isA<IOHttpClientAdapter>());
      expect((adapter as IOHttpClientAdapter).validateCertificate, isNotNull);
    });

    test('validator returns false when no pinned certificates', () {
      final der = Uint8List.fromList([0x30, 0x31, 0x32]);
      expect(
        validateCert(der, const DevEnvironment().pinnedCertificates),
        isFalse,
      );
    });

    test('validator returns true when hash matches pinned certificate', () {
      final der = Uint8List.fromList([0x30, 0x31, 0x32]);
      final hash = sha256.convert(der).toString();
      expect(validateCert(der, [hash]), isTrue);
    });

    test('validator returns false when hash does not match', () {
      final der = Uint8List.fromList([0x30, 0x31, 0x32]);
      expect(
        validateCert(der, [
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        ]),
        isFalse,
      );
    });

    test('sha256 of DER bytes produces a 64-char hex string', () {
      final derBytes = Uint8List.fromList([0x30, 0x31, 0x32]);
      final hash = sha256.convert(derBytes).toString();

      expect(hash, isA<String>());
      expect(hash.length, 64);
      expect(hash, matches(RegExp(r'^[a-f0-9]+$')));
    });

    test('sha256 is deterministic — same DER gives same hash', () {
      final derBytes = Uint8List.fromList([0x30, 0x31, 0x32]);
      final hash1 = sha256.convert(derBytes).toString();
      final hash2 = sha256.convert(derBytes).toString();
      expect(hash1, hash2);
    });

    test('different DER bytes produce different hashes', () {
      final der1 = Uint8List.fromList([0x30, 0x31, 0x32]);
      final der2 = Uint8List.fromList([0x40, 0x41, 0x42]);
      final hash1 = sha256.convert(der1).toString();
      final hash2 = sha256.convert(der2).toString();
      expect(hash1, isNot(hash2));
    });
  });

  group('DioWrapper _request connectivity exception handling', () {
    test(
      'TimeoutException from _checkConnectivity is caught and converted to AppTimeoutException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenThrow(TimeoutException('Simulated timeout'));

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<AppTimeoutException>()),
        );
      },
    );

    test(
      'no internet pre-check throws NoConnectionException (preserves NetworkError mapping)',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => false);

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<NoConnectionException>()),
        );
      },
    );
  });

  group('DioWrapper _request parser exception handling', () {
    test('unexpected parser error is sanitized (no raw error leak)', () async {
      final dio = Dio();
      final wrapper = DioWrapper(
        mockInternetService,
        dio,
        null,
        null,
        _ThrowingParser(Exception('SECRET internal detail')),
      );

      when(
        () => mockInternetService.isConnected(),
      ).thenAnswer((_) async => true);
      when(
        () => mockInternetService.isServerReachable(),
      ).thenAnswer((_) async => true);
      dio.interceptors.add(_SuccessInterceptor());

      expect(
        () => wrapper.get(Uri.parse('https://example.com')),
        throwsA(
          isA<UnexpectedResponseException>().having(
            (e) => e.details,
            'details',
            allOf(
              isNot(contains('SECRET')),
              contains('Unexpected internal error'),
            ),
          ),
        ),
      );
    });

    test(
      'parser UnexpectedResponseException is rethrown without double wrapping',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(
          mockInternetService,
          dio,
          null,
          null,
          const _ThrowingParser(
            UnexpectedResponseException('original details'),
          ),
        );

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);
        dio.interceptors.add(_SuccessInterceptor());

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(
            isA<UnexpectedResponseException>().having(
              (e) => e.details,
              'details',
              'original details',
            ),
          ),
        );
      },
    );
  });

  group('DioException timeout type handling', () {
    test(
      'DioExceptionType.connectionTimeout throws AppTimeoutException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(
          _DioThrowInterceptor(timeoutType: DioExceptionType.connectionTimeout),
        );

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<AppTimeoutException>()),
        );
      },
    );

    test('DioExceptionType.sendTimeout throws AppTimeoutException', () async {
      final dio = Dio();
      final wrapper = DioWrapper(mockInternetService, dio);

      when(
        () => mockInternetService.isConnected(),
      ).thenAnswer((_) async => true);
      when(
        () => mockInternetService.isServerReachable(),
      ).thenAnswer((_) async => true);

      dio.interceptors.add(
        _DioThrowInterceptor(timeoutType: DioExceptionType.sendTimeout),
      );

      expect(
        () => wrapper.get(Uri.parse('https://example.com')),
        throwsA(isA<AppTimeoutException>()),
      );
    });

    test(
      'DioExceptionType.receiveTimeout throws AppTimeoutException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(
          _DioThrowInterceptor(timeoutType: DioExceptionType.receiveTimeout),
        );

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<AppTimeoutException>()),
        );
      },
    );

    test(
      'DioException with response status code throws ApiException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(_DioThrowInterceptor(statusCode: 500));

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<ApiException>()),
        );
      },
    );

    test(
      'DioExceptionType.connectionError without response throws NoConnectionException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(
          _DioThrowInterceptor(timeoutType: DioExceptionType.connectionError),
        );

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<NoConnectionException>()),
        );
      },
    );

    test(
      'DioException without response and not timeout throws UnexpectedResponseException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(
          _DioThrowInterceptor(timeoutType: DioExceptionType.unknown),
        );

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<UnexpectedResponseException>()),
        );
      },
    );

    test(
      'DioExceptionType.badCertificate without response throws UnexpectedResponseException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(
          _DioThrowInterceptor(timeoutType: DioExceptionType.badCertificate),
        );

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<UnexpectedResponseException>()),
        );
      },
    );

    test(
      'DioExceptionType.cancel without response throws UnexpectedResponseException',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(
          _DioThrowInterceptor(timeoutType: DioExceptionType.cancel),
        );

        expect(
          () => wrapper.get(Uri.parse('https://example.com')),
          throwsA(isA<UnexpectedResponseException>()),
        );
      },
    );
  });

  group('DioWrapper ConnectionProfile', () {
    test(
      'default profile sets connectTimeout to 10s and receiveTimeout to 15s',
      () {
        final dio = Dio();
        DioWrapper(mockInternetService, dio);
        expect(dio.options.connectTimeout, const Duration(seconds: 10));
        expect(dio.options.receiveTimeout, const Duration(seconds: 15));
      },
    );
  });

  group('DioWrapper EndpointSla', () {
    test('EndpointSla.login is accepted without error', () async {
      final dio = Dio();
      final wrapper = DioWrapper(mockInternetService, dio);

      when(
        () => mockInternetService.isConnected(),
      ).thenAnswer((_) async => true);
      when(
        () => mockInternetService.isServerReachable(),
      ).thenAnswer((_) async => true);

      dio.interceptors.add(_SuccessInterceptor());

      final result = await wrapper.get(
        Uri.parse('https://example.com'),
        sla: EndpointSla.login,
      );
      expect(result, isA<HttpResponse<Map<String, dynamic>>>());
    });

    test('not passing sla uses EndpointSla.unknown without error', () async {
      final dio = Dio();
      final wrapper = DioWrapper(mockInternetService, dio);

      when(
        () => mockInternetService.isConnected(),
      ).thenAnswer((_) async => true);
      when(
        () => mockInternetService.isServerReachable(),
      ).thenAnswer((_) async => true);

      dio.interceptors.add(_SuccessInterceptor());

      final result = await wrapper.get(Uri.parse('https://example.com'));
      expect(result, isA<HttpResponse<Map<String, dynamic>>>());
    });
  });

  group('DioWrapper retry on timeout', () {
    test('retry with idempotent sla succeeds on second attempt', () async {
      final dio = Dio();
      final wrapper = DioWrapper(mockInternetService, dio);

      when(
        () => mockInternetService.isConnected(),
      ).thenAnswer((_) async => true);
      when(
        () => mockInternetService.isServerReachable(),
      ).thenAnswer((_) async => true);

      dio.interceptors.add(
        _RetryThenSuccessInterceptor(failuresBeforeSuccess: 1),
      );

      final result = await wrapper.get(
        Uri.parse('https://example.com'),
        sla: EndpointSla.upload,
      );
      expect(result, isA<HttpResponse<Map<String, dynamic>>>());
    });

    test(
      'retry with idempotent sla exhausts all attempts then throws',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(
          _RetryThenSuccessInterceptor(failuresBeforeSuccess: 3),
        );

        expect(
          () => wrapper.get(
            Uri.parse('https://example.com'),
            sla: EndpointSla.upload,
          ),
          throwsA(
            isA<AppTimeoutException>().having(
              (e) => e.message,
              'message',
              contains('example.com'),
            ),
          ),
        );
      },
    );

    test(
      'login sla does NOT retry on timeout (login is not idempotent)',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(
          _RetryThenSuccessInterceptor(failuresBeforeSuccess: 1),
        );

        expect(
          () => wrapper.get(
            Uri.parse('https://example.com'),
            sla: EndpointSla.login,
          ),
          throwsA(isA<AppTimeoutException>()),
        );
      },
    );

    test('no retry when sla has standard retry policy', () async {
      final dio = Dio();
      final wrapper = DioWrapper(mockInternetService, dio);

      when(
        () => mockInternetService.isConnected(),
      ).thenAnswer((_) async => true);
      when(
        () => mockInternetService.isServerReachable(),
      ).thenAnswer((_) async => true);

      dio.interceptors.add(
        _RetryThenSuccessInterceptor(failuresBeforeSuccess: 1),
      );

      expect(
        () => wrapper.get(
          Uri.parse('https://example.com'),
          sla: EndpointSla.standard,
        ),
        throwsA(isA<AppTimeoutException>()),
      );
    });

    test(
      'interceptor unknown error is wrapped as UnexpectedResponseException (no retry)',
      () async {
        final dio = Dio();
        final wrapper = DioWrapper(mockInternetService, dio);

        when(
          () => mockInternetService.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockInternetService.isServerReachable(),
        ).thenAnswer((_) async => true);

        dio.interceptors.add(_TimeoutErrorInterceptor(failBeforeSuccess: 1));

        expect(
          () => wrapper.get(
            Uri.parse('https://example.com'),
            sla: EndpointSla.login,
          ),
          throwsA(isA<UnexpectedResponseException>()),
        );
      },
    );
  });
}

class _SuccessInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(
        statusCode: 200,
        requestOptions: options,
        data: <String, dynamic>{'success': true},
      ),
    );
  }
}

class _DioThrowInterceptor extends Interceptor {
  _DioThrowInterceptor({this.timeoutType, this.statusCode});

  final DioExceptionType? timeoutType;
  final int? statusCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    throw DioException(
      type: timeoutType ?? DioExceptionType.unknown,
      requestOptions: options,
      response: statusCode != null
          ? Response(statusCode: statusCode, requestOptions: options)
          : null,
    );
  }
}

class _RetryThenSuccessInterceptor extends Interceptor {
  _RetryThenSuccessInterceptor({required this.failuresBeforeSuccess});

  final int failuresBeforeSuccess;
  int _callCount = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _callCount++;
    if (_callCount <= failuresBeforeSuccess) {
      throw DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: options,
      );
    }
    handler.resolve(
      Response(
        statusCode: 200,
        requestOptions: options,
        data: <String, dynamic>{'success': true},
      ),
    );
  }
}

class _TimeoutErrorInterceptor extends Interceptor {
  _TimeoutErrorInterceptor({this.failBeforeSuccess});

  final int? failBeforeSuccess;
  int _callCount = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _callCount++;
    if (failBeforeSuccess == null || _callCount <= failBeforeSuccess!) {
      throw TimeoutException('Simulated timeout');
    }
    handler.resolve(
      Response(
        statusCode: 200,
        requestOptions: options,
        data: <String, dynamic>{'success': true},
      ),
    );
  }
}

class _ThrowingParser implements IDioResponseParser {
  const _ThrowingParser(this.error);

  final Object error;

  @override
  HttpResponse<Map<String, dynamic>> parse({
    required Response<dynamic> response,
    required String? type,
    required bool returnDioResponse,
  }) {
    throw error;
  }
}
