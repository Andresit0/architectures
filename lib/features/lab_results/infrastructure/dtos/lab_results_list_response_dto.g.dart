// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'lab_results_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LabResultsListResponseDto _$LabResultsListResponseDtoFromJson(
  Map<String, dynamic> json,
) => _LabResultsListResponseDto(
  labResults: (json['lab_results'] as List<dynamic>)
      .map((e) => LabResultDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

abstract final class _$LabResultsListResponseDtoJsonKeys {
  static const String labResults = 'lab_results';
}

Map<String, dynamic> _$LabResultsListResponseDtoToJson(
  _LabResultsListResponseDto instance,
) => <String, dynamic>{
  'lab_results': instance.labResults.map((e) => e.toJson()).toList(),
};
