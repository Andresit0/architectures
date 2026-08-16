// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_diagnosis_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryDiagnosisDto _$ClinicalHistoryDiagnosisDtoFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryDiagnosisDto(
  code: json['code'] as String,
  name: json['name'] as String,
);

abstract final class _$ClinicalHistoryDiagnosisDtoJsonKeys {
  static const String code = 'code';
  static const String name = 'name';
}

Map<String, dynamic> _$ClinicalHistoryDiagnosisDtoToJson(
  _ClinicalHistoryDiagnosisDto instance,
) => <String, dynamic>{'code': instance.code, 'name': instance.name};
