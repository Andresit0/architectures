import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_response_parser.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late IDioResponseParser parser;

  setUp(() {
    parser = const DioResponseParser();
  });

  group('parse', () {
    test('returnDioResponse=true returns HttpSuccess without data', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: 'anything',
        statusCode: 200,
      );

      final result = parser.parse(
        response: response,
        type: null,
        returnDioResponse: true,
      );

      expect(result, isA<HttpSuccess>());
      expect(result.statusCode, 200);
      expect(result.data, isNull);
    });

    test('bytes type with List<int> data returns HttpSuccess', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: <int>[72, 101, 108],
        statusCode: 200,
      );

      final result = parser.parse(
        response: response,
        type: 'bytes',
        returnDioResponse: false,
      );

      expect(result, isA<HttpSuccess>());
      expect(result.statusCode, 200);
      expect(result.data, isNull);
    });

    test(
      'bytes type with non-List<int> data throws UnexpectedResponseException',
      () {
        final response = Response(
          requestOptions: RequestOptions(path: ''),
          data: 'not bytes',
          statusCode: 200,
        );

        expect(
          () => parser.parse(
            response: response,
            type: 'bytes',
            returnDioResponse: false,
          ),
          throwsA(
            isA<UnexpectedResponseException>().having(
              (e) => e.details,
              'details',
              allOf(isNot(contains('Respuesta')), contains('String')),
            ),
          ),
        );
      },
    );

    test('image type returns HttpSuccess', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: null,
        statusCode: 200,
      );

      final result = parser.parse(
        response: response,
        type: 'image',
        returnDioResponse: false,
      );

      expect(result, isA<HttpSuccess>());
      expect(result.statusCode, 200);
      expect(result.data, isNull);
    });

    test('already-decoded Map data returns HttpSuccess with data', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: <String, dynamic>{'key': 'value'},
        statusCode: 200,
      );

      final result = parser.parse(
        response: response,
        type: null,
        returnDioResponse: false,
      );

      expect(result, isA<HttpSuccess>());
      expect(result.statusCode, 200);
      expect((result as HttpSuccess).data, {'key': 'value'});
    });

    test('already-decoded List data returns HttpSuccess without data', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: <dynamic>['a', 'b'],
        statusCode: 200,
      );

      final result = parser.parse(
        response: response,
        type: null,
        returnDioResponse: false,
      );

      expect(result, isA<HttpSuccess>());
      expect(result.statusCode, 200);
      expect(result.data, isNull);
    });

    test(
      'non-2xx status throws UnexpectedResponseException (handled upstream)',
      () {
        final response = Response(
          requestOptions: RequestOptions(path: ''),
          data: {'message': 'Unauthorized'},
          statusCode: 401,
        );

        expect(
          () => parser.parse(
            response: response,
            type: null,
            returnDioResponse: false,
          ),
          throwsA(isA<UnexpectedResponseException>()),
        );
      },
    );

    test('unexpected body type throws UnexpectedResponseException', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: 42,
        statusCode: 200,
      );

      expect(
        () => parser.parse(
          response: response,
          type: null,
          returnDioResponse: false,
        ),
        throwsA(isA<UnexpectedResponseException>()),
      );
    });

    test('JSON response decodes correctly into Map', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: <int>[
          123,
          34,
          107,
          101,
          121,
          34,
          58,
          32,
          34,
          118,
          97,
          108,
          117,
          101,
          34,
          125,
        ],
      );

      final result = parser.parse(
        response: response,
        type: null,
        returnDioResponse: false,
      );

      expect(result, isA<HttpSuccess<Map<String, dynamic>>>());
      expect(result.statusCode, 200);
      expect(result.data, {'key': 'value'});
    });

    test('JSON response that is a List returns HttpSuccess without data', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: <int>[91, 34, 97, 34, 44, 32, 34, 98, 34, 93],
      );

      final result = parser.parse(
        response: response,
        type: null,
        returnDioResponse: false,
      );

      expect(result, isA<HttpSuccess>());
      expect(result.statusCode, 200);
      expect(result.data, isNull);
    });

    test('statusCode 200 con JSON body → HttpSuccess', () {
      final response = Response(
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'ok'},
      );
      final result = parser.parse(
        response: response,
        type: null,
        returnDioResponse: false,
      );
      expect(result, isA<HttpSuccess>());
      expect(result.statusCode, equals(200));
      expect((result as HttpSuccess).data, equals({'message': 'ok'}));
    });

    test('statusCode 201 → HttpSuccess', () {
      final response = Response(
        statusCode: 201,
        requestOptions: RequestOptions(path: '/test'),
        data: <int>[123, 34, 105, 100, 34, 58, 32, 49, 125],
      );
      final result = parser.parse(
        response: response,
        type: null,
        returnDioResponse: false,
      );
      expect(result, isA<HttpSuccess>());
      expect(result.statusCode, equals(201));
      expect((result as HttpSuccess).data, equals({'id': 1}));
    });
  });
}
