import 'package:clean_architecture_sdd_harness/core/services/crypto/bcrypt_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BcryptWrapper', () {
    late BcryptWrapper hasher;

    setUp(() {
      hasher = const BcryptWrapper();
    });

    test('hash returns a non-empty string', () async {
      final result = await hasher.hash('myPassword123!');
      expect(result, isNotEmpty);
      expect(result, isA<String>());
    });

    test('hash produces different outputs for same password (salt)', () async {
      final result1 = await hasher.hash('myPassword123!');
      final result2 = await hasher.hash('myPassword123!');
      expect(result1, isNot(result2));
    });
  });
}
