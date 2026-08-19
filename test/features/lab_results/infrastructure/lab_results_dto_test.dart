import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/features/lab_results/infrastructure/dtos/_dtos.lib.dart';

const _numericWithRangeJson = <String, dynamic>{
  'id': 'lr_0001',
  'test_code': 'HB',
  'test_name': 'Hemoglobina',
  'category': 'Hematología',
  'unit': 'g/dL',
  'kind': 'numeric',
  'reference_range': <String, dynamic>{'low': 13.0, 'high': 17.0},
  'values': <Map<String, dynamic>>[
    <String, dynamic>{'date': '2026-08-10', 'value': 16.8},
    <String, dynamic>{'date': '2026-06-14', 'value': 15.4},
  ],
};

const _numericNoRangeJson = <String, dynamic>{
  'id': 'lr_0004',
  'test_code': 'PCR',
  'test_name': 'Proteína C reactiva',
  'category': 'Inmunología',
  'unit': 'mg/L',
  'kind': 'numeric',
  'reference_range': null,
  'values': <Map<String, dynamic>>[
    <String, dynamic>{'date': '2026-08-10', 'value': 2.4},
  ],
};

const _textJson = <String, dynamic>{
  'id': 'lr_0005',
  'test_code': 'GRUPO',
  'test_name': 'Grupo sanguíneo',
  'category': 'Inmunohematología',
  'unit': null,
  'kind': 'text',
  'reference_range': null,
  'values': <Map<String, dynamic>>[
    <String, dynamic>{'date': '2026-08-10', 'value': 'A Positivo (A+)'},
  ],
};

const _labResultsJson = <String, dynamic>{
  'lab_results': <Map<String, dynamic>>[
    _numericWithRangeJson,
    _numericNoRangeJson,
    _textJson,
  ],
};

void main() {
  group('LabResultsListResponseDto', () {
    test('fromJson parses the lab_results list', () {
      final dto = LabResultsListResponseDto.fromJson(_labResultsJson);

      expect(dto.labResults, hasLength(3));
      expect(dto.labResults.first.id, 'lr_0001');
      expect(dto.labResults[2].kind, 'text');
    });

    test('fromJson throws when lab_results is missing', () {
      expect(
        () => LabResultsListResponseDto.fromJson(<String, dynamic>{}),
        throwsA(isA<Object>()),
      );
    });

    test('toJson roundtrip preserves parsed fields', () {
      final dto = LabResultsListResponseDto.fromJson(_labResultsJson);
      final restored = LabResultsListResponseDto.fromJson(dto.toJson());

      expect(restored.labResults, hasLength(3));
      expect(restored.labResults.first.id, 'lr_0001');
      expect(restored.labResults.first.unit, 'g/dL');
    });
  });

  group('LabResultDto', () {
    test('fromJson parses numeric result with reference range', () {
      final dto = LabResultDto.fromJson(_numericWithRangeJson);

      expect(dto.id, 'lr_0001');
      expect(dto.testCode, 'HB');
      expect(dto.testName, 'Hemoglobina');
      expect(dto.category, 'Hematología');
      expect(dto.unit, 'g/dL');
      expect(dto.kind, 'numeric');
      expect(dto.referenceRange?.low, 13.0);
      expect(dto.referenceRange?.high, 17.0);
      expect(dto.values, hasLength(2));
      expect(dto.values.first.date, DateTime(2026, 8, 10));
      expect(dto.values.first.value, 16.8);
    });

    test('fromJson parses text result with null unit and range', () {
      final dto = LabResultDto.fromJson(_textJson);

      expect(dto.unit, isNull);
      expect(dto.kind, 'text');
      expect(dto.referenceRange, isNull);
      expect(dto.values.single.value, 'A Positivo (A+)');
    });

    test('fromJson parses numeric result with null reference range', () {
      final dto = LabResultDto.fromJson(_numericNoRangeJson);

      expect(dto.referenceRange, isNull);
      expect(dto.values.single.value, 2.4);
    });

    test('toJson roundtrip preserves every field', () {
      final dto = LabResultDto.fromJson(_numericWithRangeJson);
      final restored = LabResultDto.fromJson(dto.toJson());

      expect(restored.id, dto.id);
      expect(restored.testCode, dto.testCode);
      expect(restored.testName, dto.testName);
      expect(restored.category, dto.category);
      expect(restored.unit, dto.unit);
      expect(restored.kind, dto.kind);
      expect(restored.referenceRange?.low, dto.referenceRange?.low);
      expect(restored.referenceRange?.high, dto.referenceRange?.high);
      expect(restored.values, hasLength(dto.values.length));
      for (var i = 0; i < dto.values.length; i++) {
        expect(restored.values[i].date, dto.values[i].date);
        expect(restored.values[i].value, dto.values[i].value);
      }
    });
  });

  group('LabResultValueDto', () {
    test('fromJson parses date and value', () {
      final dto = LabResultValueDto.fromJson(const <String, dynamic>{
        'date': '2026-08-10',
        'value': 16.8,
      });

      expect(dto.date, DateTime(2026, 8, 10));
      expect(dto.value, 16.8);
    });

    test('fromJson preserves a text value', () {
      final dto = LabResultValueDto.fromJson(const <String, dynamic>{
        'date': '2026-08-10',
        'value': 'A Positivo (A+)',
      });

      expect(dto.value, 'A Positivo (A+)');
    });

    test('toJson roundtrip preserves date and value', () {
      final dto = LabResultValueDto.fromJson(const <String, dynamic>{
        'date': '2026-08-10',
        'value': 16.8,
      });
      final restored = LabResultValueDto.fromJson(dto.toJson());

      expect(restored.date, dto.date);
      expect(restored.value, dto.value);
    });

    test('freezed copyWith mutates a single field', () {
      final dto = LabResultValueDto.fromJson(const <String, dynamic>{
        'date': '2026-08-10',
        'value': 16.8,
      });

      expect(dto.copyWith(value: 15.4).value, 15.4);
      expect(dto.copyWith(value: 15.4).date, DateTime(2026, 8, 10));
    });

    test('freezed value equality compares structurally', () {
      final a = LabResultValueDto.fromJson(const <String, dynamic>{
        'date': '2026-08-10',
        'value': 16.8,
      });
      final b = LabResultValueDto.fromJson(const <String, dynamic>{
        'date': '2026-08-10',
        'value': 16.8,
      });

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('LabResultReferenceRangeDto', () {
    test('fromJson parses low and high', () {
      final dto = LabResultReferenceRangeDto.fromJson(const <String, dynamic>{
        'low': 13.0,
        'high': 17.0,
      });

      expect(dto.low, 13.0);
      expect(dto.high, 17.0);
    });

    test('toJson roundtrip preserves low and high', () {
      final dto = LabResultReferenceRangeDto.fromJson(const <String, dynamic>{
        'low': 13.0,
        'high': 17.0,
      });
      final restored = LabResultReferenceRangeDto.fromJson(dto.toJson());

      expect(restored.low, dto.low);
      expect(restored.high, dto.high);
    });
  });
}
