import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

void main() {
  group('deriveLabResultStatus', () {
    test('value within range returns normal', () {
      const range = LabResultReferenceRangeEntity(low: 13.0, high: 17.0);

      expect(deriveLabResultStatus(14.8, range), LabResultStatus.normal);
    });

    test('value above high returns high', () {
      const range = LabResultReferenceRangeEntity(low: 70.0, high: 110.0);

      expect(deriveLabResultStatus(128.0, range), LabResultStatus.high);
    });

    test('value below low returns low', () {
      const range = LabResultReferenceRangeEntity(low: 3.5, high: 5.1);

      expect(deriveLabResultStatus(3.2, range), LabResultStatus.low);
    });

    test('null range returns unknown', () {
      expect(deriveLabResultStatus(2.4, null), LabResultStatus.unknown);
      expect(deriveLabResultStatus(null, null), LabResultStatus.unknown);
    });

    test('boundary values are normal (inclusive bounds)', () {
      const range = LabResultReferenceRangeEntity(low: 13.0, high: 17.0);

      expect(deriveLabResultStatus(13.0, range), LabResultStatus.normal);
      expect(deriveLabResultStatus(17.0, range), LabResultStatus.normal);
    });
  });
}
