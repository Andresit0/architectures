import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

void main() {
  final baseRange = const LabResultReferenceRangeEntity(low: 13.0, high: 17.0);

  final baseValues = [
    LabResultValueEntity(
      date: DateTime(2026, 1, 15),
      value: 14.8,
      textValue: null,
    ),
    LabResultValueEntity(
      date: DateTime(2026, 8, 10),
      value: 15.2,
      textValue: null,
    ),
  ];

  final baseEntity = LabResultEntity(
    id: 'res-001',
    testCode: 'GLU',
    testName: 'Glucose',
    category: 'Chemistry',
    unit: 'mg/dL',
    kind: LabResultKind.numeric,
    referenceRange: baseRange,
    values: baseValues,
  );

  group('LabResultEntity (reused from shared/models)', () {
    test('is constructible via the shared models barrel', () {
      expect(baseEntity.id, 'res-001');
      expect(baseEntity.testCode, 'GLU');
      expect(baseEntity.testName, 'Glucose');
      expect(baseEntity.category, 'Chemistry');
      expect(baseEntity.unit, 'mg/dL');
      expect(baseEntity.kind, LabResultKind.numeric);
      expect(baseEntity.referenceRange, baseRange);
      expect(baseEntity.values.length, 2);
      expect(baseEntity.values.last.value, 15.2);
      expect(baseEntity.values.last.textValue, isNull);
    });

    test('equality uses value semantics', () {
      final same = LabResultEntity(
        id: 'res-001',
        testCode: 'GLU',
        testName: 'Glucose',
        category: 'Chemistry',
        unit: 'mg/dL',
        kind: LabResultKind.numeric,
        referenceRange: baseRange,
        values: baseValues,
      );

      expect(baseEntity, equals(same));
    });

    test('copyWith creates a modified copy', () {
      final copy = baseEntity.copyWith(testName: 'Glucose (plasma)');
      expect(copy.testName, 'Glucose (plasma)');
      expect(copy.id, 'res-001');
    });

    test('status getter uses the latest value', () {
      final entity = LabResultEntity(
        id: 'res-001',
        testCode: 'GLU',
        testName: 'Glucose',
        category: 'Chemistry',
        unit: 'mg/dL',
        kind: LabResultKind.numeric,
        referenceRange: baseRange,
        values: [
          LabResultValueEntity(
            date: DateTime(2026, 1, 15),
            value: 15.0,
            textValue: null,
          ),
          LabResultValueEntity(
            date: DateTime(2026, 8, 10),
            value: 20.0,
            textValue: null,
          ),
        ],
      );

      expect(entity.status, LabResultStatus.high);
    });

    test('latestValue returns null for empty values', () {
      final empty = LabResultEntity(
        id: 'res-001',
        testCode: 'GLU',
        testName: 'Glucose',
        category: 'Chemistry',
        unit: 'mg/dL',
        kind: LabResultKind.numeric,
        referenceRange: baseRange,
        values: const [],
      );

      expect(empty.latestValue, isNull);
    });

    test('latestValue returns the most recent value regardless of order', () {
      final unordered = LabResultEntity(
        id: 'res-001',
        testCode: 'GLU',
        testName: 'Glucose',
        category: 'Chemistry',
        unit: 'mg/dL',
        kind: LabResultKind.numeric,
        referenceRange: baseRange,
        values: [
          LabResultValueEntity(
            date: DateTime(2026, 8, 10),
            value: 15.2,
            textValue: null,
          ),
          LabResultValueEntity(
            date: DateTime(2026, 1, 15),
            value: 14.8,
            textValue: null,
          ),
        ],
      );

      expect(unordered.latestValue?.date, DateTime(2026, 8, 10));
      expect(unordered.latestValue?.value, 15.2);
    });
  });

  group('LabResultValueEntity / LabResultReferenceRangeEntity', () {
    test('numeric value entity carries value and null textValue', () {
      final value = LabResultValueEntity(
        date: DateTime(2026, 1, 15),
        value: 14.8,
        textValue: null,
      );
      expect(value.value, 14.8);
      expect(value.textValue, isNull);
    });

    test('text value entity carries textValue and null value', () {
      final value = LabResultValueEntity(
        date: DateTime(2026, 1, 15),
        value: null,
        textValue: 'Negative',
      );
      expect(value.value, isNull);
      expect(value.textValue, 'Negative');
    });

    test('reference range exposes low and high', () {
      expect(baseRange.low, 13.0);
      expect(baseRange.high, 17.0);
    });
  });
}
