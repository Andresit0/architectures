import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('SecureTokenStore — unit tests', () {
    late FakeSecureStorage storage;
    late SecureTokenStore store;

    setUp(() {
      storage = FakeSecureStorage();
      store = SecureTokenStore(storage: storage);
    });

    test('implements ITokenStore', () {
      expect(store, isA<ITokenStore>());
    });

    test('read returns null when nothing stored', () async {
      expect(await store.read(), isNull);
    });

    test('save + read roundtrip returns the stored token', () async {
      await store.save('jwt-token-123');

      final result = await store.read();
      expect(result, 'jwt-token-123');
    });

    test('delete removes the token', () async {
      await store.save('jwt-token-123');
      expect(await store.read(), isNotNull);

      await store.delete();
      expect(await store.read(), isNull);
    });

    test('delete clears the in-memory cache', () async {
      await store.save('jwt-token-123');
      await store.delete();

      final result = await store.read();
      expect(result, isNull);
    });
  });
}
