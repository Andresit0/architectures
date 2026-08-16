// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_professional_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryProfessionalDto _$ClinicalHistoryProfessionalDtoFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryProfessionalDto(
  id: json['id'] as String,
  fullname: json['fullname'] as String,
  specialty: json['specialty'] as String,
);

abstract final class _$ClinicalHistoryProfessionalDtoJsonKeys {
  static const String id = 'id';
  static const String fullname = 'fullname';
  static const String specialty = 'specialty';
}

Map<String, dynamic> _$ClinicalHistoryProfessionalDtoToJson(
  _ClinicalHistoryProfessionalDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullname': instance.fullname,
  'specialty': instance.specialty,
};
