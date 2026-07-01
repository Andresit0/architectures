import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/database/app_database.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockIDatabaseKeyService extends Mock implements IDatabaseKeyService {}

const _validKey = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
const _alternateKey = 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=';

// `exp` claim is 2100-01-01 (Unix: 4102444800).
const _nonExpiredToken =
    'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjQxMDI0NDQ4MDB9.fake_sig';

// `exp` claim is in the past (Unix: 10).
const _expiredToken = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjEwfQ.sig';

void main() {
  group('CpDrift — unit tests (mock database)', () {
    late MockAppDatabase mockDatabase;
    late MockIDatabaseKeyService mockKeyService;
    late CpDrift cpDrift;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockKeyService = MockIDatabaseKeyService();
      cpDrift = CpDrift(mockDatabase, mockKeyService, CpEncrypt());
    });

    test('implements ICpDrift', () {
      expect(cpDrift, isA<ICpDrift>());
    });

    group('readSession', () {
      test('returns null when database returns null', () async {
        when(() => mockKeyService.readKey()).thenAnswer((_) async => _validKey);
        when(() => mockDatabase.readSession()).thenAnswer((_) async => null);

        final result = await cpDrift.readSession();

        expect(result, isNull);
        verify(() => mockDatabase.readSession()).called(1);
      });

      test('when key is absent (data wiped), clears DB, saves new key, '
          'returns null', () async {
        when(() => mockKeyService.readKey()).thenAnswer((_) async => null);
        when(() => mockKeyService.generateKey()).thenReturn(_alternateKey);
        when(() => mockKeyService.saveKey(any())).thenAnswer((_) async {});
        when(() => mockDatabase.clearSession()).thenAnswer((_) async {});
        when(() => mockDatabase.readSession()).thenAnswer((_) async => null);

        final result = await cpDrift.readSession();

        expect(result, isNull);
        verifyInOrder([
          () => mockDatabase.clearSession(),
          () => mockKeyService.saveKey(_alternateKey),
        ]);
      });

      test(
        'caches the key after first read (calls readKey only once)',
        () async {
          when(
            () => mockKeyService.readKey(),
          ).thenAnswer((_) async => _validKey);
          when(() => mockDatabase.readSession()).thenAnswer((_) async => null);

          await cpDrift.readSession();
          await cpDrift.readSession();

          verify(() => mockKeyService.readKey()).called(1);
        },
      );
    });

    group('clearSession', () {
      test('delegates directly to AppDatabase.clearSession', () async {
        when(() => mockDatabase.clearSession()).thenAnswer((_) async {});

        await cpDrift.clearSession();

        verify(() => mockDatabase.clearSession()).called(1);
      });
    });

    group('saveSession', () {
      test('stores encrypted values, not plaintext', () async {
        when(() => mockKeyService.readKey()).thenAnswer((_) async => _validKey);
        when(
          () => mockDatabase.saveSession(
            fullname: any(named: 'fullname'),
            token: any(named: 'token'),
          ),
        ).thenAnswer((_) async {});

        await cpDrift.saveSession(fullname: 'John Doe', token: 'secret_token');

        final captured = verify(
          () => mockDatabase.saveSession(
            fullname: captureAny(named: 'fullname'),
            token: captureAny(named: 'token'),
          ),
        ).captured;

        final storedFullname = captured[0] as String;
        final storedToken = captured[1] as String;

        expect(storedFullname, isNot('John Doe'));
        expect(storedToken, isNot('secret_token'));

        expect(storedFullname, isNotEmpty);
        expect(storedToken, isNotEmpty);
        expect(() => base64Url.decode(storedFullname), returnsNormally);
        expect(() => base64Url.decode(storedToken), returnsNormally);
      });
    });
  });

  group('CpDrift — integration tests (in-memory database)', () {
    late AppDatabase inMemoryDb;
    late MockIDatabaseKeyService mockKeyService;
    late CpDrift cpDrift;

    setUp(() {
      inMemoryDb = AppDatabase(NativeDatabase.memory());
      mockKeyService = MockIDatabaseKeyService();
      cpDrift = CpDrift(inMemoryDb, mockKeyService, CpEncrypt());
    });

    tearDown(() async => inMemoryDb.close());

    test(
      'saveSession + readSession roundtrip returns decrypted values',
      () async {
        when(() => mockKeyService.readKey()).thenAnswer((_) async => _validKey);

        await cpDrift.saveSession(
          fullname: 'Jane Doe',
          token: _nonExpiredToken,
        );

        final session = await cpDrift.readSession();

        expect(session, isNotNull);
        expect(session!.fullname, 'Jane Doe');
        expect(session.token, _nonExpiredToken);
      },
    );

    test('stored rows contain ciphertext, not plaintext', () async {
      when(() => mockKeyService.readKey()).thenAnswer((_) async => _validKey);

      await cpDrift.saveSession(fullname: 'Jane Doe', token: _nonExpiredToken);

      final raw = await inMemoryDb.readSession();
      expect(raw!.fullname, isNot('Jane Doe'));
      expect(raw.token, isNot(_nonExpiredToken));
    });

    test(
      'readSession clears session and returns null for expired token',
      () async {
        when(() => mockKeyService.readKey()).thenAnswer((_) async => _validKey);

        await cpDrift.saveSession(fullname: 'Jane Doe', token: _expiredToken);

        final session = await cpDrift.readSession();

        expect(session, isNull);
        final raw = await inMemoryDb.readSession();
        expect(raw, isNull);
      },
    );

    test('data-wipe scenario: key absent → DB cleared → new key saved → '
        'returns null', () async {
      when(() => mockKeyService.readKey()).thenAnswer((_) async => _validKey);
      await cpDrift.saveSession(fullname: 'Jane Doe', token: _nonExpiredToken);

      final postWipeCpDrift = CpDrift(inMemoryDb, mockKeyService, CpEncrypt());
      when(() => mockKeyService.readKey()).thenAnswer((_) async => null);
      when(() => mockKeyService.generateKey()).thenReturn(_alternateKey);
      when(
        () => mockKeyService.saveKey(_alternateKey),
      ).thenAnswer((_) async {});

      final result = await postWipeCpDrift.readSession();

      expect(result, isNull);
      verify(() => mockKeyService.saveKey(_alternateKey)).called(1);
      final raw = await inMemoryDb.readSession();
      expect(raw, isNull);
    });

    test(
      'decryption failure (corrupted data) clears session and returns null',
      () async {
        when(() => mockKeyService.readKey()).thenAnswer((_) async => _validKey);
        await cpDrift.saveSession(
          fullname: 'Jane Doe',
          token: _nonExpiredToken,
        );

        final wrongKeyCpDrift = CpDrift(inMemoryDb, mockKeyService, CpEncrypt());
        when(
          () => mockKeyService.readKey(),
        ).thenAnswer((_) async => _alternateKey);

        final result = await wrongKeyCpDrift.readSession();

        expect(result, isNull);
        final raw = await inMemoryDb.readSession();
        expect(raw, isNull);
      },
    );
  });
}
