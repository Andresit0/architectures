import 'lab_result_reference_range_dto.dart';
import 'lab_result_value_dto.dart';

class LabResultDto {
  const LabResultDto({
    required this.id,
    required this.testCode,
    required this.testName,
    required this.category,
    required this.unit,
    required this.kind,
    required this.referenceRange,
    required this.values,
  });

  factory LabResultDto.fromJson(Map<String, dynamic> json) => LabResultDto(
    id: json['id'] as String,
    testCode: json['test_code'] as String,
    testName: json['test_name'] as String,
    category: json['category'] as String,
    unit: json['unit'] as String?,
    kind: json['kind'] as String,
    referenceRange: json['reference_range'] == null
        ? null
        : LabResultReferenceRangeDto.fromJson(
            json['reference_range'] as Map<String, dynamic>,
          ),
    values: (json['values'] as List<dynamic>)
        .map((e) => LabResultValueDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String id;
  final String testCode;
  final String testName;
  final String category;
  final String? unit;
  final String kind;
  final LabResultReferenceRangeDto? referenceRange;
  final List<LabResultValueDto> values;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'test_code': testCode,
    'test_name': testName,
    'category': category,
    'unit': unit,
    'kind': kind,
    'reference_range': referenceRange?.toJson(),
    'values': values.map((e) => e.toJson()).toList(),
  };
}
