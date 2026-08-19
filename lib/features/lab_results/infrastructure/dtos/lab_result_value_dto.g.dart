// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'lab_result_value_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LabResultValueDto _$LabResultValueDtoFromJson(Map<String, dynamic> json) =>
    _LabResultValueDto(
      date: DateTime.parse(json['date'] as String),
      value: json['value'],
    );

abstract final class _$LabResultValueDtoJsonKeys {
  static const String date = 'date';
  static const String value = 'value';
}

Map<String, dynamic> _$LabResultValueDtoToJson(_LabResultValueDto instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
    };
