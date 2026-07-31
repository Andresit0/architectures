import 'package:clean_architecture_sdd_harness/shared/interfaces/i_password_hasher.dart';
import 'package:clean_architecture_sdd_harness/core/services/crypto/password_hasher_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('passwordHasherProvider', () {
    test('should provide an IPasswordHasher', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final hasher = container.read(passwordHasherProvider);
      expect(hasher, isA<IPasswordHasher>());
    });
  });
}
