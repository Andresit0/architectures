// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'patient_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatientDto _$PatientDtoFromJson(Map<String, dynamic> json) =>
    _PatientDto(id: json['id'] as String, name: json['name'] as String);

abstract final class _$PatientDtoJsonKeys {
  static const String id = 'id';
  static const String name = 'name';
}

Map<String, dynamic> _$PatientDtoToJson(_PatientDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
