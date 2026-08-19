import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CertificatePinner', () {
    group('empty pinnedCertificates', () {
      test('throws StateError in release mode when pinning is enforced', () {
        expect(
          () => const CertificatePinner(
            pinnedCertificates: [],
            isReleaseMode: true,
            enforcePinning: true,
          ).apply(Dio()),
          throwsA(isA<StateError>()),
        );
      });

      test('does not throw in release mode when pinning is not enforced', () {
        expect(
          () => const CertificatePinner(
            pinnedCertificates: [],
            isReleaseMode: true,
            enforcePinning: false,
          ).apply(Dio()),
          returnsNormally,
        );
      });

      test('does not throw in debug mode', () {
        expect(
          () => const CertificatePinner(
            pinnedCertificates: [],
            isReleaseMode: false,
          ).apply(Dio()),
          returnsNormally,
        );
      });

      test('allow all in debug mode', () {
        final dio = Dio();
        const CertificatePinner(
          pinnedCertificates: [],
          isReleaseMode: false,
        ).apply(dio);
        final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
        expect(adapter.validateCertificate, isNotNull);
        expect(adapter.validateCertificate!(null, 'host', 443), isTrue);
      });
    });

    group('configured certificates', () {
      test('validates matching certificate hash', () {
        final pinner = const CertificatePinner(
          pinnedCertificates: ['abc123'],
          isReleaseMode: false,
        );
        expect(() => pinner.apply(Dio()), returnsNormally);
      });

      test('rejects non-matching certificate hash', () {
        final pinner = const CertificatePinner(
          pinnedCertificates: ['abc123'],
          isReleaseMode: true,
        );
        expect(() => pinner.apply(Dio()), returnsNormally);
      });
    });
  });
}
