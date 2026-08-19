import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('SecureCredentialStore — unit tests', () {
    late FakeSecureStorage storage;
    late SecureCredentialStore store;

    setUp(() {
      storage = FakeSecureStorage();
      store = SecureCredentialStore(storage: storage);
    });

    test('implements ICredentialStore', () {
      expect(store, isA<ICredentialStore>());
    });

    test('readCredentials returns null when nothing stored', () async {
      expect(await store.readCredentials(), isNull);
    });

    test(
      'saveCredentials + readCredentials roundtrip returns the record',
      () async {
        await store.saveCredentials(
          email: 'john@example.com',
          passwordHash: 'bcrypt-hash-123',
        );

        final result = await store.readCredentials();
        expect(result, isNotNull);
        expect(result!.email, 'john@example.com');
        expect(result.passwordHash, 'bcrypt-hash-123');
      },
    );

    test(
      'readCredentials returns null when only one field is stored',
      () async {
        await storage.write(
          key: 'tudesarrollador_login_email',
          value: 'john@example.com',
        );

        final result = await store.readCredentials();
        expect(result, isNull);
      },
    );

    test('deleteCredentials removes the stored credentials', () async {
      await store.saveCredentials(
        email: 'john@example.com',
        passwordHash: 'bcrypt-hash-123',
      );
      expect(await store.readCredentials(), isNotNull);

      await store.deleteCredentials();
      expect(await store.readCredentials(), isNull);
    });
  });
}
