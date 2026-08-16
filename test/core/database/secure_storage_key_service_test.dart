import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_sdd_harness/core/database/secure_storage_key_service.dart';
import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';

class MockISecureStorageWrapper extends Mock implements ISecureStorageWrapper {}

void main() {
  late DatabaseKeyService keyService;
  late MockISecureStorageWrapper mockStorage;

  setUp(() {
    mockStorage = MockISecureStorageWrapper();
    keyService = DatabaseKeyService(storage: mockStorage);
  });

  group('DatabaseKeyService', () {
    group('readKey', () {
      test('returns existing key from storage', () async {
        when(
          () => mockStorage.read(key: 'db_encryption_key'),
        ).thenAnswer((_) async => 'existing_key_value');

        final result = await keyService.readKey();

        expect(result, 'existing_key_value');
        verify(() => mockStorage.read(key: 'db_encryption_key')).called(1);
      });

      test('returns null when no key is stored', () async {
        when(
          () => mockStorage.read(key: 'db_encryption_key'),
        ).thenAnswer((_) async => null);

        final result = await keyService.readKey();

        expect(result, isNull);
      });
    });

    group('saveKey', () {
      test('writes key to secure storage', () async {
        when(
          () => mockStorage.write(
            key: 'db_encryption_key',
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        await keyService.saveKey('my_test_key');

        verify(
          () =>
              mockStorage.write(key: 'db_encryption_key', value: 'my_test_key'),
        ).called(1);
      });
    });

    group('deleteKey', () {
      test('removes key from secure storage', () async {
        when(
          () => mockStorage.delete(key: 'db_encryption_key'),
        ).thenAnswer((_) async {});

        await keyService.deleteKey();

        verify(() => mockStorage.delete(key: 'db_encryption_key')).called(1);
      });
    });

    group('generateKey', () {
      test('returns a non-empty string', () {
        final key = keyService.generateKey();
        expect(key, isNotEmpty);
      });

      test('returns a valid base64url-encoded value', () {
        final key = keyService.generateKey();
        expect(() => base64Url.decode(key), returnsNormally);
      });

      test('decoded key is exactly 32 bytes (AES-256)', () {
        final key = keyService.generateKey();
        final bytes = base64Url.decode(key);
        expect(bytes.length, 32);
      });

      test('generates a different key on each call', () {
        final key1 = keyService.generateKey();
        final key2 = keyService.generateKey();
        expect(key1, isNot(equals(key2)));
      });

      test('implements IDatabaseKeyService', () {
        expect(keyService, isA<IDatabaseKeyService>());
      });
    });
  });
}
