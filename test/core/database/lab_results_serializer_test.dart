import 'package:clean_architecture_sdd_harness/core/database/serializers/lab_results_serializer.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LabResultsSerializer round-trip', () {
    test('numeric entity survives toMap + fromMap', () {
      final entity = LabResultEntity(
        id: 'lr_0001',
        testCode: 'HB',
        testName: 'Hemoglobina',
        category: 'Hematología',
        unit: 'g/dL',
        kind: LabResultKind.numeric,
        referenceRange: const LabResultReferenceRangeEntity(
          low: 13.0,
          high: 17.0,
        ),
        values: [
          LabResultValueEntity(
            date: DateTime(2026, 8, 10),
            value: 16.8,
            textValue: null,
          ),
        ],
      );

      final map = LabResultsSerializer.toMap(entity);
      final restored = LabResultsSerializer.fromMap(map);

      expect(restored, entity);
    });

    test('text entity with null unit/range survives round-trip', () {
      final entity = LabResultEntity(
        id: 'lr_0005',
        testCode: 'GRUPO',
        testName: 'Grupo sanguíneo',
        category: 'Inmunohematología',
        unit: null,
        kind: LabResultKind.text,
        referenceRange: null,
        values: [
          LabResultValueEntity(
            date: DateTime(2026, 8, 10),
            value: null,
            textValue: 'A Positivo (A+)',
          ),
        ],
      );

      final map = LabResultsSerializer.toMap(entity);
      final restored = LabResultsSerializer.fromMap(map);

      expect(restored, entity);
    });

    test('multiple values survive round-trip', () {
      final entity = LabResultEntity(
        id: 'lr_0002',
        testCode: 'PCR',
        testName: 'Proteína C reactiva',
        category: 'Inmunología',
        unit: 'mg/L',
        kind: LabResultKind.numeric,
        referenceRange: null,
        values: [
          LabResultValueEntity(
            date: DateTime(2026, 8, 10),
            value: 2.4,
            textValue: null,
          ),
          LabResultValueEntity(
            date: DateTime(2026, 6, 14),
            value: 3.1,
            textValue: null,
          ),
        ],
      );

      final map = LabResultsSerializer.toMap(entity);
      final restored = LabResultsSerializer.fromMap(map);

      expect(restored, entity);
    });

    test('toMap uses a value-kind discriminator', () {
      final numericMap = LabResultsSerializer.toMap(
        LabResultEntity(
          id: 'n',
          testCode: 'T1',
          testName: 'Numeric',
          category: 'cat',
          unit: null,
          kind: LabResultKind.numeric,
          referenceRange: null,
          values: [
            LabResultValueEntity(
              date: DateTime(2026, 8, 10),
              value: 16.8,
              textValue: null,
            ),
          ],
        ),
      );
      final textMap = LabResultsSerializer.toMap(
        LabResultEntity(
          id: 't',
          testCode: 'T2',
          testName: 'Text',
          category: 'cat',
          unit: null,
          kind: LabResultKind.text,
          referenceRange: null,
          values: [
            LabResultValueEntity(
              date: DateTime(2026, 8, 10),
              value: null,
              textValue: 'A+',
            ),
          ],
        ),
      );

      expect(
        ((numericMap['values'] as List).single as Map<String, dynamic>)['kind'],
        'numeric',
      );
      expect(
        ((textMap['values'] as List).single as Map<String, dynamic>)['kind'],
        'text',
      );
    });
  });
}
