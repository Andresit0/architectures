import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

Email _valid(String v) => (Email.result(v) as Success<Email>).data;

void main() {
  group('Email.result', () {
    test('returns Success with Email for a valid address', () {
      expect(Email.result('test@example.com').isSuccess, isTrue);
      expect(_valid('test@example.com').value, 'test@example.com');
    });

    test(
      'returns Failure with ValidationError field=email for empty string',
      () {
        final result = Email.result('');
        final error = (result as Failure<Email>).error;
        expect(error, isA<ValidationError>());
        expect((error as ValidationError).field, 'email');
      },
    );

    test('returns Failure for email without @', () {
      expect(Email.result('notanemail').isSuccess, isFalse);
    });

    test('regex accepts standard addresses', () {
      const valid = [
        'user@example.com',
        'first.last@example.co',
        'user+tag@example.org',
        'user_name@example.io',
      ];
      for (final email in valid) {
        expect(
          Email.result(email).isSuccess,
          isTrue,
          reason: '$email should be valid',
        );
      }
    });

    test('regex rejects malformed addresses', () {
      const invalid = [
        'plainaddress',
        'missing-at.example.com',
        'missing-domain@',
        '@example.com',
        'user@.com',
        'user@example',
        'user name@example.com',
      ];
      for (final email in invalid) {
        expect(
          Email.result(email).isSuccess,
          isFalse,
          reason: '$email should be invalid',
        );
      }
    });

    test('equality works correctly', () {
      final email1 = _valid('test@example.com');
      final email2 = _valid('test@example.com');
      final email3 = _valid('other@example.com');

      expect(email1, equals(email2));
      expect(email1, isNot(equals(email3)));
    });
  });
}
