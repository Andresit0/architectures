// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_service_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryServiceDto _$ClinicalHistoryServiceDtoFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryServiceDto(
  code: json['code'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
);

abstract final class _$ClinicalHistoryServiceDtoJsonKeys {
  static const String code = 'code';
  static const String name = 'name';
  static const String category = 'category';
}

Map<String, dynamic> _$ClinicalHistoryServiceDtoToJson(
  _ClinicalHistoryServiceDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'category': instance.category,
};
