import 'package:freezed_annotation/freezed_annotation.dart';

import 'lab_result_reference_range_dto.dart';
import 'lab_result_value_dto.dart';

part 'lab_result_dto.freezed.dart';
part 'lab_result_dto.g.dart';

@freezed
abstract class LabResultDto with _$LabResultDto {
  const factory LabResultDto({
    required String id,
    @JsonKey(name: 'test_code') required String testCode,
    @JsonKey(name: 'test_name') required String testName,
    required String category,
    String? unit,
    required String kind,
    @JsonKey(name: 'reference_range')
    LabResultReferenceRangeDto? referenceRange,
    required List<LabResultValueDto> values,
  }) = _LabResultDto;

  factory LabResultDto.fromJson(Map<String, dynamic> json) =>
      _$LabResultDtoFromJson(json);
}
