import 'package:freezed_annotation/freezed_annotation.dart';

part 'lab_result_reference_range_dto.freezed.dart';
part 'lab_result_reference_range_dto.g.dart';

@freezed
abstract class LabResultReferenceRangeDto with _$LabResultReferenceRangeDto {
  const factory LabResultReferenceRangeDto({
    required double low,
    required double high,
  }) = _LabResultReferenceRangeDto;

  factory LabResultReferenceRangeDto.fromJson(Map<String, dynamic> json) =>
      _$LabResultReferenceRangeDtoFromJson(json);
}
