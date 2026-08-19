import 'package:clean_architecture_sdd_harness/core/services/auth/jwt_wrapper.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JwtWrapper', () {
    late JwtWrapper wrapper;

    setUp(() {
      wrapper = const JwtWrapper();
    });

    group('decodePayload', () {
      const secret = 'my_secret_key';

      test('should return the payload claims for a valid token', () {
        final token = JWT({
          'sub': '123',
          'role': 'admin',
        }).sign(SecretKey(secret));

        final result = wrapper.decodePayload(token);

        expect(result, isNotNull);
        expect(result?['sub'], '123');
        expect(result?['role'], 'admin');
      });

      test('should return null for a malformed token', () {
        expect(wrapper.decodePayload('not.a.jwt'), isNull);
      });

      test('should decode a tampered signature (decode does not verify)', () {
        final validToken = JWT({'sub': '123'}).sign(SecretKey(secret));
        final parts = validToken.split('.');
        final tamperedSignature = '${parts[0]}.${parts[1]}.AAAA';

        final result = wrapper.decodePayload(tamperedSignature);

        expect(result, isNotNull);
        expect(result?['sub'], '123');
      });

      test('should return null when the payload is not a JSON object', () {
        final token = JWT('plain-string-payload').sign(SecretKey(secret));

        expect(wrapper.decodePayload(token), isNull);
      });
    });
  });
}
