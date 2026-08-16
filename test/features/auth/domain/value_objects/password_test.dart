import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

Password _valid(String v) => (Password.result(v) as Success<Password>).data;

void main() {
  group('Password.result', () {
    test('returns Success with Password for a valid value', () {
      expect(Password.result('valid123').isSuccess, isTrue);
      expect(_valid('valid123').value, 'valid123');
    });

    test(
      'returns Failure with ValidationError field=password for empty password',
      () {
        final result = Password.result('');
        final error = (result as Failure<Password>).error;
        expect(error, isA<ValidationError>());
        expect((error as ValidationError).field, 'password');
      },
    );

    test('returns Failure for password shorter than 6 characters', () {
      expect(Password.result('abc').isSuccess, isFalse);
    });

    test('supports value equality', () {
      expect(_valid('password123'), equals(_valid('password123')));
    });
  });
}
