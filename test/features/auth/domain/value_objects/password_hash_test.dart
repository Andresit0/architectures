import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';

void main() {
  group('PasswordHash', () {
    test('create with valid hash returns PasswordHash instance', () {
      final hash = PasswordHash.create('\$2a\$10\$7s0ve9d8kF5bG5cH7jK5eO');
      expect(hash, isA<PasswordHash>());
      expect(hash.value, '\$2a\$10\$7s0ve9d8kF5bG5cH7jK5eO');
    });

    test('create with empty hash throws FormatException', () {
      expect(
        () => PasswordHash.create(''),
        throwsA(isA<FormatException>()),
      );
    });

    test('tryCreate returns null for empty string', () {
      expect(PasswordHash.tryCreate(''), isNull);
    });

    test('tryCreate returns PasswordHash for valid hash', () {
      final hash = PasswordHash.tryCreate('somehashvalue');
      expect(hash, isNotNull);
      expect(hash!.value, 'somehashvalue');
    });

    test('equality works correctly', () {
      final hash1 = PasswordHash.create('hash1');
      final hash2 = PasswordHash.create('hash1');
      final hash3 = PasswordHash.create('hash2');

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hash3)));
    });
  });
}
