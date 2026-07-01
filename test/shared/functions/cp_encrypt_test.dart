import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

const _validKey = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
const _alternateKey = 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=';

void main() {
  group('CpEncrypt', () {
    late CpEncrypt cpEncrypt;

    setUp(() {
      cpEncrypt = CpEncrypt();
    });

    test('implements ICpEncrypt', () {
      expect(cpEncrypt, isA<ICpEncrypt>());
    });

    group('encrypt', () {
      test('returns a non-empty string', () {
        final result = cpEncrypt.encrypt('hello', _validKey);
        expect(result, isNotEmpty);
      });

      test('does not return plaintext', () {
        final result = cpEncrypt.encrypt('hello world', _validKey);
        expect(result, isNot('hello world'));
      });

      test('returns a valid base64url-encoded string', () {
        final result = cpEncrypt.encrypt('hello', _validKey);
        expect(() => base64Url.decode(result), returnsNormally);
      });

      test('produces different ciphertext for the same plaintext (random IV)', () {
        final result1 = cpEncrypt.encrypt('hello', _validKey);
        final result2 = cpEncrypt.encrypt('hello', _validKey);
        expect(result1, isNot(result2));
      });

      test('encoded result contains IV (16 bytes) + ciphertext overhead', () {
        final result = cpEncrypt.encrypt('hello', _validKey);
        final decoded = base64Url.decode(result);
        expect(decoded.length, greaterThan(16));
      });
    });

    group('decrypt', () {
      test('roundtrip: decrypt(encrypt(plain, key), key) returns plain', () {
        const plaintext = 'secret message 123';
        final encrypted = cpEncrypt.encrypt(plaintext, _validKey);
        final decrypted = cpEncrypt.decrypt(encrypted, _validKey);
        expect(decrypted, plaintext);
      });

      test('roundtrip preserves unicode characters', () {
        const plaintext = 'Héllo Wörld 日本語';
        final encrypted = cpEncrypt.encrypt(plaintext, _validKey);
        final decrypted = cpEncrypt.decrypt(encrypted, _validKey);
        expect(decrypted, plaintext);
      });

      test('roundtrip is consistent across multiple values', () {
        const values = ['alpha', 'beta', 'gamma 123!'];
        for (final v in values) {
          expect(cpEncrypt.decrypt(cpEncrypt.encrypt(v, _validKey), _validKey), v);
        }
      });

      test('throws when decrypting with wrong key', () {
        final encrypted = cpEncrypt.encrypt('hello', _validKey);
        expect(
          () => cpEncrypt.decrypt(encrypted, _alternateKey),
          throwsA(anything),
        );
      });
    });
  });
}
