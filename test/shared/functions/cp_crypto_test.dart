import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

void main() {
  group('CpCrypto', () {
    late CpCrypto cpCrypto;

    setUp(() {
      cpCrypto = CpCrypto();
    });

    test('sha256 returns a non-empty hex string for valid input', () {
      final result = cpCrypto.sha256('hello');
      expect(result, isNotEmpty);
      expect(result, isA<String>());
    });

    test('sha256 returns a 64-character hex string (SHA-256)', () {
      final result = cpCrypto.sha256('hello');
      expect(result.length, 64);
    });

    test('sha256 hex string contains only valid hex characters', () {
      final result = cpCrypto.sha256('hello');
      expect(result, matches(RegExp(r'^[a-f0-9]+$')));
    });

    test('sha256 is deterministic — same input gives same hash', () {
      final result1 = cpCrypto.sha256('hello');
      final result2 = cpCrypto.sha256('hello');
      expect(result1, result2);
    });

    test('sha256 produces different hash for different inputs', () {
      final result1 = cpCrypto.sha256('hello');
      final result2 = cpCrypto.sha256('world');
      expect(result1, isNot(result2));
    });

    test('sha256 handles empty string', () {
      final result = cpCrypto.sha256('');
      expect(result.length, 64);
      expect(result, matches(RegExp(r'^[a-f0-9]+$')));
    });

    test('sha256 handles unicode characters', () {
      final result = cpCrypto.sha256('Héllo Wörld 日本語');
      expect(result.length, 64);
      expect(result, matches(RegExp(r'^[a-f0-9]+$')));
    });
  });
}
