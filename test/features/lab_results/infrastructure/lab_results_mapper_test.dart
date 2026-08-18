import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/infrastructure/dtos/_dtos.lib.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/infrastructure/mappers/lab_results_mapper.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

final _numericDto = LabResultDto(
  id: 'lr_0001',
  testCode: 'HB',
  testName: 'Hemoglobina',
  category: 'Hematología',
  unit: 'g/dL',
  kind: 'numeric',
  referenceRange: LabResultReferenceRangeDto(low: 13.0, high: 17.0),
  values: [
    LabResultValueDto(date: DateTime(2026, 8, 10), value: 16.8),
    LabResultValueDto(date: DateTime(2026, 6, 14), value: 15.4),
  ],
);

final _numericNoRangeDto = LabResultDto(
  id: 'lr_0004',
  testCode: 'PCR',
  testName: 'Proteína C reactiva',
  category: 'Inmunología',
  unit: 'mg/L',
  kind: 'numeric',
  referenceRange: null,
  values: [LabResultValueDto(date: DateTime(2026, 8, 10), value: 2.4)],
);

final _textDto = LabResultDto(
  id: 'lr_0005',
  testCode: 'GRUPO',
  testName: 'Grupo sanguíneo',
  category: 'Inmunohematología',
  unit: null,
  kind: 'text',
  referenceRange: null,
  values: [
    LabResultValueDto(date: DateTime(2026, 8, 10), value: 'A Positivo (A+)'),
  ],
);

void main() {
  group('LabResultsMapper', () {
    group('fromDto', () {
      test('maps a numeric result with reference range', () {
        final entity = LabResultsMapper.fromDto(_numericDto);

        expect(entity.id, 'lr_0001');
        expect(entity.testCode, 'HB');
        expect(entity.testName, 'Hemoglobina');
        expect(entity.category, 'Hematología');
        expect(entity.unit, 'g/dL');
        expect(entity.kind, LabResultKind.numeric);
        expect(entity.referenceRange?.low, 13.0);
        expect(entity.referenceRange?.high, 17.0);
        expect(entity.values, hasLength(2));
        for (final value in entity.values) {
          expect(value.value, isNotNull);
          expect(value.textValue, isNull);
        }
      });

      test('maps a numeric result with null reference range', () {
        final entity = LabResultsMapper.fromDto(_numericNoRangeDto);

        expect(entity.kind, LabResultKind.numeric);
        expect(entity.referenceRange, isNull);
        expect(entity.values.single.value, 2.4);
        expect(entity.values.single.textValue, isNull);
      });

      test('maps a text result with null unit and range', () {
        final entity = LabResultsMapper.fromDto(_textDto);

        expect(entity.kind, LabResultKind.text);
        expect(entity.unit, isNull);
        expect(entity.referenceRange, isNull);
        expect(entity.values.single.value, isNull);
        expect(entity.values.single.textValue, 'A Positivo (A+)');
      });

      test('silently nulls a mismatched wire type on a numeric kind', () {
        final dto = LabResultDto(
          id: 'lr_x',
          testCode: 'X',
          testName: 'X',
          category: 'X',
          unit: null,
          kind: 'numeric',
          referenceRange: null,
          values: [
            LabResultValueDto(date: DateTime(2026, 8, 10), value: '16.8'),
          ],
        );

        final entity = LabResultsMapper.fromDto(dto);

        expect(entity.values.single.value, isNull);
        expect(entity.values.single.textValue, isNull);
      });

      test('falls back to text kind for an unknown code', () {
        final dto = LabResultDto(
          id: 'lr_x',
          testCode: 'X',
          testName: 'X',
          category: 'X',
          unit: null,
          kind: 'foo',
          referenceRange: null,
          values: [
            LabResultValueDto(date: DateTime(2026, 8, 10), value: 'texto'),
          ],
        );

        final entity = LabResultsMapper.fromDto(dto);

        expect(entity.kind, LabResultKind.text);
        expect(entity.values.single.textValue, 'texto');
      });
    });

    group('fromDtoList', () {
      test('maps every item preserving order', () {
        final entities = LabResultsMapper.fromDtoList([_numericDto, _textDto]);

        expect(entities, hasLength(2));
        expect(entities.first.id, 'lr_0001');
        expect(entities.last.kind, LabResultKind.text);
      });

      test('returns an empty list for an empty input', () {
        expect(LabResultsMapper.fromDtoList(const <LabResultDto>[]), isEmpty);
      });
    });

    group('VGV compliance', () {
      test('NO usa Entity.fromJson en ninguna parte', () {
        final sourceFile = File(
          'lib/features/lab_results/infrastructure/mappers/lab_results_mapper.dart',
        );
        final source = sourceFile.readAsStringSync();
        expect(
          source.contains('.fromJson'),
          isFalse,
          reason: 'El mapper no debe contener ninguna llamada a .fromJson',
        );
      });
    });
  });
}
