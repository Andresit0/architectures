// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryListResponseDto _$ClinicalHistoryListResponseDtoFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryListResponseDto(
  clinicalHistory:
      (json['clinical_history'] as List<dynamic>?)
          ?.map((e) => ClinicalHistoryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

abstract final class _$ClinicalHistoryListResponseDtoJsonKeys {
  static const String clinicalHistory = 'clinical_history';
}

Map<String, dynamic> _$ClinicalHistoryListResponseDtoToJson(
  _ClinicalHistoryListResponseDto instance,
) => <String, dynamic>{
  'clinical_history': instance.clinicalHistory.map((e) => e.toJson()).toList(),
};
