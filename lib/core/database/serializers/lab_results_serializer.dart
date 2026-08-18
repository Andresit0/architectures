import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_kind.dart';
import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_reference_range_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_value_entity.dart';

class LabResultsSerializer {
  static Map<String, dynamic> toMap(LabResultEntity entity) => {
    'id': entity.id,
    'test_code': entity.testCode,
    'test_name': entity.testName,
    'category': entity.category,
    if (entity.unit != null) 'unit': entity.unit,
    'kind': entity.kind.name,
    if (entity.referenceRange != null)
      'reference_range': _referenceRangeToMap(entity.referenceRange!),
    'values': entity.values.map(_valueToMap).toList(),
  };

  static LabResultEntity fromMap(Map<String, dynamic> map) => LabResultEntity(
    id: map['id'] as String,
    testCode: map['test_code'] as String,
    testName: map['test_name'] as String,
    category: map['category'] as String,
    unit: map['unit'] as String?,
    kind: LabResultKind.fromCode(map['kind'] as String?),
    referenceRange: map['reference_range'] != null
        ? _referenceRangeFromMap(map['reference_range'] as Map<String, dynamic>)
        : null,
    values: (map['values'] as List<dynamic>)
        .map((e) => _valueFromMap(e as Map<String, dynamic>))
        .toList(),
  );

  static Map<String, dynamic> _referenceRangeToMap(
    LabResultReferenceRangeEntity e,
  ) => {'low': e.low, 'high': e.high};

  static LabResultReferenceRangeEntity _referenceRangeFromMap(
    Map<String, dynamic> m,
  ) => LabResultReferenceRangeEntity(
    low: (m['low'] as num).toDouble(),
    high: (m['high'] as num).toDouble(),
  );

  static Map<String, dynamic> _valueToMap(LabResultValueEntity v) => {
    'date': v.date.toIso8601String(),
    'kind': v.value != null
        ? LabResultKind.numeric.name
        : LabResultKind.text.name,
    if (v.value != null) 'value': v.value,
    if (v.textValue != null) 'text_value': v.textValue,
  };

  static LabResultValueEntity _valueFromMap(Map<String, dynamic> m) {
    final kind = LabResultKind.fromCode(m['kind'] as String?);
    final raw = m['value'];
    final text = m['text_value'];
    return switch (kind) {
      LabResultKind.numeric => LabResultValueEntity(
        date: DateTime.parse(m['date'] as String),
        value: raw is num ? raw.toDouble() : null,
        textValue: null,
      ),
      LabResultKind.text => LabResultValueEntity(
        date: DateTime.parse(m['date'] as String),
        value: null,
        textValue: text is String ? text : null,
      ),
    };
  }
}
