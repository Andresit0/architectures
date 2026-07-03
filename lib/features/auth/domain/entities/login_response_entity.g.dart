// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponseEntity _$LoginResponseEntityFromJson(Map<String, dynamic> json) =>
    _LoginResponseEntity(
      patient: PatientEntity.fromJson(json['patient'] as Map<String, dynamic>),
      token: TokenEntity.fromJson(json['token'] as Map<String, dynamic>),
      clinicalHistory: (json['clinical_history'] as List<dynamic>?)
          ?.map(
            (e) => ClinicalHistoryEntity.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$LoginResponseEntityToJson(
  _LoginResponseEntity instance,
) => <String, dynamic>{
  'patient': instance.patient,
  'token': instance.token,
  'clinical_history': instance.clinicalHistory,
};
