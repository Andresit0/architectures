import 'package:clean_architecture_sdd_harness/core/services/auth/jwt_wrapper.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JwtWrapper', () {
    late JwtWrapper wrapper;

    setUp(() {
      wrapper = const JwtWrapper();
    });

    group('verifySignature', () {
      const secret = 'my_secret_key';
      const differentSecret = 'different_secret';
      late String validToken;

      setUp(() {
        validToken = JWT({'sub': '123'}).sign(SecretKey(secret));
      });

      test(
          'should return true for a valid token signed with correct secret',
          () {
        final result = wrapper.verifySignature(validToken, secret);

        expect(result, isTrue);
      });

      test('should return false for a tampered token', () {
        final parts = validToken.split('.');
        final tamperedToken = '${parts[0]}.tamperedPayload.${parts[2]}';

        final result = wrapper.verifySignature(tamperedToken, secret);

        expect(result, isFalse);
      });

      test('should return false for a token signed with different secret',
          () {
        final result =
            wrapper.verifySignature(validToken, differentSecret);

        expect(result, isFalse);
      });

      test('should return false for an invalid token format', () {
        final result = wrapper.verifySignature('not.a.jwt', secret);

        expect(result, isFalse);
      });
    });
  });
}
