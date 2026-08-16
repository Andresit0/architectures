import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_state_dto.freezed.dart';
part 'clinical_history_state_dto.g.dart';

@freezed
abstract class ClinicalHistoryStateDto with _$ClinicalHistoryStateDto {
  const factory ClinicalHistoryStateDto({
    required String code,
    required String label,
  }) = _ClinicalHistoryStateDto;

  factory ClinicalHistoryStateDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryStateDtoFromJson(json);
}
