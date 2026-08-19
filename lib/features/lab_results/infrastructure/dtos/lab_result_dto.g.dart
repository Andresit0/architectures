// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'lab_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LabResultDto _$LabResultDtoFromJson(Map<String, dynamic> json) =>
    _LabResultDto(
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

abstract final class _$LabResultDtoJsonKeys {
  static const String id = 'id';
  static const String testCode = 'test_code';
  static const String testName = 'test_name';
  static const String category = 'category';
  static const String unit = 'unit';
  static const String kind = 'kind';
  static const String referenceRange = 'reference_range';
  static const String values = 'values';
}

Map<String, dynamic> _$LabResultDtoToJson(_LabResultDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'test_code': instance.testCode,
      'test_name': instance.testName,
      'category': instance.category,
      'unit': instance.unit,
      'kind': instance.kind,
      'reference_range': instance.referenceRange?.toJson(),
      'values': instance.values.map((e) => e.toJson()).toList(),
    };
