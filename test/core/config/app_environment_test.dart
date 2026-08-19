import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveUseHttps', () {
    test('returns true when the port is 443', () {
      expect(resolveUseHttps(443, false), isTrue);
    });

    test('returns true when https is forced regardless of port', () {
      expect(resolveUseHttps(5111, true), isTrue);
    });

    test('returns false for a non-443 port without forcing https', () {
      expect(resolveUseHttps(5111, false), isFalse);
    });
  });

  group('AppEnvironment', () {
    test('DevEnvironment uses https only when forced', () {
      const env = DevEnvironment();
      expect(env.port, 5111);
      expect(env.host, isNotEmpty);
      expect(env.requirePinnedCertificates, isFalse);
    });

    test('StagingEnvironment requires pinned certificates', () {
      expect(const StagingEnvironment().requirePinnedCertificates, isTrue);
    });

    test('ProductionEnvironment requires pinned certificates', () {
      expect(const ProductionEnvironment().requirePinnedCertificates, isTrue);
    });
  });
}
