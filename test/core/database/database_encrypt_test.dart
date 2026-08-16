import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/core/database/database_encrypt.dart';

void main() {
  group('buildEncryptCodec', () {
    test('round-trips a map value', () {
      final codec = buildEncryptCodec('password-123');
      const value = {
        'a': 1,
        'b': 'x',
        'c': [1, 2, 3],
      };

      final encoded = codec.encode(value);
      final decoded = codec.decode(encoded);

      expect(decoded, value);
    });

    test('round-trips a string and an int', () {
      final codec = buildEncryptCodec('password-123');

      expect(codec.decode(codec.encode('hello')), 'hello');
      expect(codec.decode(codec.encode(42)), 42);
    });

    test('produces a unique IV per encryption', () {
      final codec = buildEncryptCodec('password-123');

      final first = codec.encode({'k': 'v'});
      final second = codec.encode({'k': 'v'});

      expect(first, isNot(second));
    });

    test('fails to decrypt with a wrong key', () {
      final encoder = buildEncryptCodec('key-A');
      final decoder = buildEncryptCodec('key-B');

      final encoded = encoder.encode({'k': 'v'});

      expect(() => decoder.decode(encoded), throwsFormatException);
    });

    test('rejects input too short to contain an IV', () {
      final codec = buildEncryptCodec('password-123');

      expect(() => codec.decode('too-short'), throwsFormatException);
    });

    test('rejects tampered ciphertext', () {
      final codec = buildEncryptCodec('password-123');
      final encoded = codec.encode({'k': 'v'});
      final tampered = 'A${encoded.substring(1)}';

      expect(() => codec.decode(tampered), throwsFormatException);
    });
  });
}
