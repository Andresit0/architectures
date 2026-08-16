import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password.dart';

void main() {
  group('Password', () {
    test('creates Password with valid value', () {
      final password = Password.create('valid123');
      expect(password.value, 'valid123');
    });

    test('throws FormatException for empty password', () {
      expect(() => Password.create(''), throwsFormatException);
    });

    test('throws FormatException for password shorter than 6 characters', () {
      expect(() => Password.create('abc'), throwsFormatException);
    });

    test('supports value equality', () {
      final a = Password.create('password123');
      final b = Password.create('password123');
      expect(a, equals(b));
    });

    test('tryCreate returns null for empty string', () {
      expect(Password.tryCreate(''), isNull);
    });

    test('tryCreate returns null for short string', () {
      expect(Password.tryCreate('abc12'), isNull);
    });

    test('tryCreate returns Password for valid password', () {
      final pass = Password.tryCreate('validPass123');
      expect(pass, isNotNull);
      expect(pass!.value, 'validPass123');
    });
  });
}
