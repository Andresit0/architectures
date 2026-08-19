import 'package:freezed_annotation/freezed_annotation.dart';

import 'lab_result_dto.dart';

part 'lab_results_list_response_dto.freezed.dart';
part 'lab_results_list_response_dto.g.dart';

@freezed
abstract class LabResultsListResponseDto with _$LabResultsListResponseDto {
  const factory LabResultsListResponseDto({
    @JsonKey(name: 'lab_results') required List<LabResultDto> labResults,
  }) = _LabResultsListResponseDto;

  factory LabResultsListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LabResultsListResponseDtoFromJson(json);
}
