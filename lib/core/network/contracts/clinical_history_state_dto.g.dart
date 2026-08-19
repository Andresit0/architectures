// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryStateDto _$ClinicalHistoryStateDtoFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryStateDto(
  code: json['code'] as String,
  label: json['label'] as String,
);

abstract final class _$ClinicalHistoryStateDtoJsonKeys {
  static const String code = 'code';
  static const String label = 'label';
}

Map<String, dynamic> _$ClinicalHistoryStateDtoToJson(
  _ClinicalHistoryStateDto instance,
) => <String, dynamic>{'code': instance.code, 'label': instance.label};
