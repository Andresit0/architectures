import 'package:clean_architecture_sdd_harness/core/services/auth/jwt_token_expiry_checker.dart';
import 'package:clean_architecture_sdd_harness/core/services/auth/jwt_wrapper.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JwtTokenExpiryChecker', () {
    const secret = 'my_secret_key';
    late JwtTokenExpiryChecker checker;

    setUp(() {
      checker = JwtTokenExpiryChecker(jwtWrapper: const JwtWrapper());
    });

    int epochSeconds(DateTime dt) => dt.toUtc().millisecondsSinceEpoch ~/ 1000;

    test('returns true for a malformed token', () async {
      expect(await checker.isExpired('not.a.jwt'), isTrue);
    });

    test('returns false when the token has no exp claim', () async {
      final token = JWT({'sub': '123'}).sign(SecretKey(secret));
      expect(await checker.isExpired(token), isFalse);
    });

    test('returns true when the token is expired (exp in the past)', () async {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      final token = JWT({
        'sub': '123',
        'exp': epochSeconds(past),
      }).sign(SecretKey(secret));
      expect(await checker.isExpired(token), isTrue);
    });

    test(
      'returns false when the token is not expired (exp in the future)',
      () async {
        final future = DateTime.now().add(const Duration(hours: 1));
        final token = JWT({
          'sub': '123',
          'exp': epochSeconds(future),
        }).sign(SecretKey(secret));
        expect(await checker.isExpired(token), isFalse);
      },
    );
  });
}
