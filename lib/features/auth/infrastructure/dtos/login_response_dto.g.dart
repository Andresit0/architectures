// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'login_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    _LoginResponseDto(
      patient: PatientDto.fromJson(json['patient'] as Map<String, dynamic>),
      token: TokenDto.fromJson(json['token'] as Map<String, dynamic>),
      clinicalHistory:
          (json['clinical_history'] as List<dynamic>?)
              ?.map(
                (e) => ClinicalHistoryDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

abstract final class _$LoginResponseDtoJsonKeys {
  static const String patient = 'patient';
  static const String token = 'token';
  static const String clinicalHistory = 'clinical_history';
}

Map<String, dynamic> _$LoginResponseDtoToJson(
  _LoginResponseDto instance,
) => <String, dynamic>{
  'patient': instance.patient.toJson(),
  'token': instance.token.toJson(),
  'clinical_history': instance.clinicalHistory.map((e) => e.toJson()).toList(),
};
