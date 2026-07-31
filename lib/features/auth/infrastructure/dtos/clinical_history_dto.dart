import 'package:freezed_annotation/freezed_annotation.dart';

import 'clinical_history_attachment_dto.dart';
import 'clinical_history_diagnosis_dto.dart';
import 'clinical_history_facility_dto.dart';
import 'clinical_history_professional_dto.dart';
import 'clinical_history_service_dto.dart';
import 'clinical_history_state_dto.dart';

part 'clinical_history_dto.freezed.dart';
part 'clinical_history_dto.g.dart';

@freezed
abstract class ClinicalHistoryDto with _$ClinicalHistoryDto {
  const factory ClinicalHistoryDto({
    required String id,
    @JsonKey(name: 'encounter_number') required String encounterNumber,
    required ClinicalHistoryServiceDto service,
    required ClinicalHistoryFacilityDto facility,
    required ClinicalHistoryProfessionalDto? professional,
    @JsonKey(name: 'encounter_date') required String encounterDate,
    @JsonKey(name: 'created_at') required DateTime? createdAt,
    @JsonKey(name: 'updated_at') required DateTime? updatedAt,
    @JsonKey(name: 'published_at') required DateTime? publishedAt,
    required String? summary,
    required String? description,
    @Default([]) List<ClinicalHistoryDiagnosisDto> diagnosis,
    @Default([]) List<String> observations,
    @Default([]) List<ClinicalHistoryAttachmentDto> attachments,
    required ClinicalHistoryStateDto? state,
  }) = _ClinicalHistoryDto;

  factory ClinicalHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryDtoFromJson(json);
}
