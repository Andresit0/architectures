import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_professional_dto.freezed.dart';
part 'clinical_history_professional_dto.g.dart';

@freezed
abstract class ClinicalHistoryProfessionalDto
    with _$ClinicalHistoryProfessionalDto {
  const factory ClinicalHistoryProfessionalDto({
    required String id,
    required String fullname,
    required String specialty,
  }) = _ClinicalHistoryProfessionalDto;

  factory ClinicalHistoryProfessionalDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryProfessionalDtoFromJson(json);
}
