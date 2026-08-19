import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    group('DevEnvironment', () {
      test('host localhost', () {
        expect(const DevEnvironment().host, 'localhost');
      });

      test('port 5111', () {
        expect(const DevEnvironment().port, 5111);
      });

      test('useHttps == false', () {
        expect(const DevEnvironment().useHttps, isFalse);
      });
    });

    group('StagingEnvironment', () {});

    test('selectEnvironment() is DevEnvironment by default', () {
      expect(AppEnvironment.selectEnvironment(), isA<DevEnvironment>());
    });
  });

  group('pinnedCertificates', () {
    test('DevEnvironment returns empty list', () {
      expect(const DevEnvironment().pinnedCertificates, isEmpty);
    });

    test('StagingEnvironment returns empty list by default', () {
      expect(const StagingEnvironment().pinnedCertificates, isEmpty);
    });

    test('ProductionEnvironment returns empty list by default', () {
      expect(const ProductionEnvironment().pinnedCertificates, isEmpty);
    });
  });
}
