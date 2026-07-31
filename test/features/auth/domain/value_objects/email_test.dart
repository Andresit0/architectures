import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';

void main() {
  group('Email', () {
    test('create with valid email returns Email instance', () {
      final email = Email.create('test@example.com');
      expect(email, isA<Email>());
      expect(email.value, 'test@example.com');
    });

    test('create with empty email throws FormatException', () {
      expect(
        () => Email.create(''),
        throwsA(isA<FormatException>()),
      );
    });

    test('create with email without @ throws FormatException', () {
      expect(
        () => Email.create('notanemail'),
        throwsA(isA<FormatException>()),
      );
    });

    test('tryCreate returns null for empty string', () {
      expect(Email.tryCreate(''), isNull);
    });

    test('tryCreate returns null for string without @', () {
      expect(Email.tryCreate('invalid'), isNull);
    });

    test('tryCreate returns Email for valid email', () {
      final email = Email.tryCreate('test@example.com');
      expect(email, isNotNull);
      expect(email!.value, 'test@example.com');
    });

    test('equality works correctly', () {
      final email1 = Email.create('test@example.com');
      final email2 = Email.create('test@example.com');
      final email3 = Email.create('other@example.com');

      expect(email1, equals(email2));
      expect(email1, isNot(equals(email3)));
    });
  });
}
