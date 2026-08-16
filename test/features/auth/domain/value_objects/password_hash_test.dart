import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

PasswordHash _valid(String v) =>
    (PasswordHash.result(v) as Success<PasswordHash>).data;

void main() {
  group('PasswordHash.result', () {
    test('returns Success with PasswordHash for a valid hash', () {
      expect(
        PasswordHash.result(r'$2a$10$7s0ve9d8kF5bG5cH7jK5eO').isSuccess,
        isTrue,
      );
      expect(
        _valid(r'$2a$10$7s0ve9d8kF5bG5cH7jK5eO').value,
        r'$2a$10$7s0ve9d8kF5bG5cH7jK5eO',
      );
    });

    test('returns Failure for empty hash', () {
      expect(PasswordHash.result('').isSuccess, isFalse);
    });

    test('equality works correctly', () {
      expect(_valid('hash1'), equals(_valid('hash1')));
      expect(_valid('hash1'), isNot(equals(_valid('hash2'))));
    });
  });
}
