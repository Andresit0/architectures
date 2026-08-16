import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpSuccess', () {
    test('contains correct data and statusCode', () {
      const success = HttpSuccess<Map<String, dynamic>>(
        data: <String, dynamic>{'key': 'value'},
        statusCode: 200,
      );

      expect(success.data, {'key': 'value'});
      expect(success.statusCode, 200);
    });

    test('is an HttpResponse', () {
      const success = HttpSuccess<Map<String, dynamic>>(
        data: <String, dynamic>{'key': 'value'},
      );
      expect(success, isA<HttpResponse<Map<String, dynamic>>>());
    });

    test('can have null statusCode', () {
      const success = HttpSuccess<Map<String, dynamic>>(
        data: <String, dynamic>{},
      );
      expect(success.statusCode, isNull);
    });

    test('can have null data', () {
      const success = HttpSuccess<Map<String, dynamic>>();
      expect(success.data, isNull);
    });
  });

  group('HttpSuccess pattern matching', () {
    test('HttpSuccess is matched correctly', () {
      const HttpResponse<Map<String, dynamic>> response =
          HttpSuccess<Map<String, dynamic>>(
            data: <String, dynamic>{'result': 'ok'},
            statusCode: 200,
          );

      expect(response.data, {'result': 'ok'});
      expect(response.statusCode, 200);
    });

    test('HttpSuccess is HttpResponse', () {
      const success = HttpSuccess<Map<String, dynamic>>(
        data: <String, dynamic>{},
      );
      expect(success, isA<HttpSuccess<Map<String, dynamic>>>());
      expect(success, isA<HttpResponse<Map<String, dynamic>>>());
    });
  });
}
