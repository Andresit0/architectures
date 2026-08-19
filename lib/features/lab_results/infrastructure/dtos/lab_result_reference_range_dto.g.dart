// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'lab_result_reference_range_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LabResultReferenceRangeDto _$LabResultReferenceRangeDtoFromJson(
  Map<String, dynamic> json,
) => _LabResultReferenceRangeDto(
  low: (json['low'] as num).toDouble(),
  high: (json['high'] as num).toDouble(),
);

abstract final class _$LabResultReferenceRangeDtoJsonKeys {
  static const String low = 'low';
  static const String high = 'high';
}

Map<String, dynamic> _$LabResultReferenceRangeDtoToJson(
  _LabResultReferenceRangeDto instance,
) => <String, dynamic>{'low': instance.low, 'high': instance.high};
