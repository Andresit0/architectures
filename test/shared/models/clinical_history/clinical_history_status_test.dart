import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

void main() {
  group('ClinicalHistoryStatus.fromCode', () {
    test('maps known codes to their enum values', () {
      expect(
        ClinicalHistoryStatus.fromCode('ready'),
        ClinicalHistoryStatus.ready,
      );
      expect(
        ClinicalHistoryStatus.fromCode('pending'),
        ClinicalHistoryStatus.pending,
      );
      expect(
        ClinicalHistoryStatus.fromCode('closed'),
        ClinicalHistoryStatus.closed,
      );
    });

    test('is case-insensitive', () {
      expect(
        ClinicalHistoryStatus.fromCode('READY'),
        ClinicalHistoryStatus.ready,
      );
      expect(
        ClinicalHistoryStatus.fromCode('Closed'),
        ClinicalHistoryStatus.closed,
      );
    });

    test('falls back to unknown for null or unrecognized codes', () {
      expect(
        ClinicalHistoryStatus.fromCode(null),
        ClinicalHistoryStatus.unknown,
      );
      expect(
        ClinicalHistoryStatus.fromCode('archived'),
        ClinicalHistoryStatus.unknown,
      );
      expect(ClinicalHistoryStatus.fromCode(''), ClinicalHistoryStatus.unknown);
    });
  });

  group('ClinicalHistoryStateEntity.status', () {
    test('derives the typed status from the raw code', () {
      const entity = ClinicalHistoryStateEntity(
        code: 'ready',
        label: 'Available',
      );
      expect(entity.status, ClinicalHistoryStatus.ready);
    });

    test('derives unknown for unrecognized codes', () {
      const entity = ClinicalHistoryStateEntity(code: 'foo', label: 'Foo');
      expect(entity.status, ClinicalHistoryStatus.unknown);
    });
  });
}
