// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_facility_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryFacilityDto _$ClinicalHistoryFacilityDtoFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryFacilityDto(
  id: json['id'] as String,
  name: json['name'] as String,
  city: json['city'] as String,
);

abstract final class _$ClinicalHistoryFacilityDtoJsonKeys {
  static const String id = 'id';
  static const String name = 'name';
  static const String city = 'city';
}

Map<String, dynamic> _$ClinicalHistoryFacilityDtoToJson(
  _ClinicalHistoryFacilityDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'city': instance.city,
};
