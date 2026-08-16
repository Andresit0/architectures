import 'dart:typed_data';

import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class _UriFake extends Fake implements Uri {}

class _OptionsFake extends Fake implements Options {}

class MockHttpClientAdapter implements HttpClientAdapter {
  MockHttpClientAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('HttpReachability', () {
    late MockDio mockDio;
    late Uri baseUri;

    setUpAll(() {
      registerFallbackValue(_UriFake());
      registerFallbackValue(_OptionsFake());
    });

    setUp(() {
      mockDio = MockDio();
      baseUri = Uri(scheme: 'http', host: 'localhost', port: 8080);
    });

    group('with mocked Dio (interface mock)', () {
      test('should return true when server responds with 200', () async {
        final reachability = HttpReachability(dio: mockDio, baseUri: baseUri);
        when(
          () => mockDio.headUri<dynamic>(any(), options: any(named: 'options')),
        ).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(path: baseUri.toString()),
          ),
        );
        final result = await reachability.check();
        expect(result, isTrue);
      });

      test('should return true even on 5xx (server is reachable)', () async {
        final reachability = HttpReachability(dio: mockDio, baseUri: baseUri);
        when(
          () => mockDio.headUri<dynamic>(any(), options: any(named: 'options')),
        ).thenAnswer(
          (_) async => Response(
            statusCode: 503,
            requestOptions: RequestOptions(path: baseUri.toString()),
          ),
        );
        final result = await reachability.check();
        expect(result, isTrue);
      });

      test('should return false on DioException (network error)', () async {
        final reachability = HttpReachability(dio: mockDio, baseUri: baseUri);
        when(
          () => mockDio.headUri<dynamic>(any(), options: any(named: 'options')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: baseUri.toString()),
          ),
        );
        final result = await reachability.check();
        expect(result, isFalse);
      });
    });

    group('with real Dio + mock HttpClientAdapter', () {
      test('should return true on 200 through real Dio', () async {
        final adapter = MockHttpClientAdapter((options) async {
          return ResponseBody.fromString('', 200);
        });
        final dio = Dio()..httpClientAdapter = adapter;
        final reachability = HttpReachability(dio: dio, baseUri: baseUri);
        final result = await reachability.check();
        expect(result, isTrue);
      });

      test('should return true even on 503 through real Dio', () async {
        final adapter = MockHttpClientAdapter((options) async {
          return ResponseBody.fromString('Service Unavailable', 503);
        });
        final dio = Dio()..httpClientAdapter = adapter;
        final reachability = HttpReachability(dio: dio, baseUri: baseUri);
        final result = await reachability.check();
        expect(result, isTrue);
      });

      test(
        'should return false on connection error through real Dio',
        () async {
          final adapter = MockHttpClientAdapter((options) async {
            throw DioException(requestOptions: options);
          });
          final dio = Dio()..httpClientAdapter = adapter;
          final reachability = HttpReachability(dio: dio, baseUri: baseUri);
          final result = await reachability.check();
          expect(result, isFalse);
        },
      );
    });
  });
}
