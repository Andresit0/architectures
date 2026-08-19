import 'package:freezed_annotation/freezed_annotation.dart';

import 'clinical_history_dto.dart';

part 'clinical_history_list_response_dto.freezed.dart';
part 'clinical_history_list_response_dto.g.dart';

@freezed
abstract class ClinicalHistoryListResponseDto
    with _$ClinicalHistoryListResponseDto {
  const factory ClinicalHistoryListResponseDto({
    @JsonKey(name: 'clinical_history')
    @Default([])
    List<ClinicalHistoryDto> clinicalHistory,
  }) = _ClinicalHistoryListResponseDto;

  factory ClinicalHistoryListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryListResponseDtoFromJson(json);
}
