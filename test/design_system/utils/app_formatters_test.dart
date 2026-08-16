import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:clean_architecture_sdd_harness/design_system/utils/app_formatters.dart';

void main() {
  setUp(() async {
    await initializeDateFormatting('es');
  });

  group('formatClinicalDate', () {
    test('formats an ISO date in English', () {
      expect(formatClinicalDate('2026-01-15', locale: 'en'), 'Jan 15, 2026');
    });

    test('formats an ISO date in Spanish', () {
      expect(formatClinicalDate('2026-01-15', locale: 'es'), '15 ene 2026');
    });

    test('falls back to the raw string when the date cannot be parsed', () {
      expect(formatClinicalDate('not-a-date', locale: 'en'), 'not-a-date');
    });
  });

  group('formatBytes', () {
    test('returns bytes when under one KB', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(512), '512 B');
    });

    test('formats KB without trailing decimals', () {
      expect(formatBytes(1024), '1 KB');
      expect(formatBytes(1536), '1.5 KB');
    });

    test('rounds large KB values to a whole number', () {
      expect(formatBytes(248530), '243 KB');
    });

    test('formats MB and larger units', () {
      expect(formatBytes(2097152), '2 MB');
    });
  });
}
