import 'package:freezed_annotation/freezed_annotation.dart';

import 'clinical_history_attachment_entity.dart';
import 'clinical_history_diagnosis_entity.dart';
import 'clinical_history_facility_entity.dart';
import 'clinical_history_professional_entity.dart';
import 'clinical_history_service_entity.dart';
import 'clinical_history_state_entity.dart';

part 'clinical_history_entity.freezed.dart';

@freezed
abstract class ClinicalHistoryEntity with _$ClinicalHistoryEntity {
  const ClinicalHistoryEntity._();

  const factory ClinicalHistoryEntity({
    required String id,
    required String encounterNumber,
    required ClinicalHistoryServiceEntity service,
    required ClinicalHistoryFacilityEntity facility,
    required ClinicalHistoryProfessionalEntity? professional,
    required String encounterDate,
    required DateTime? createdAt,
    required DateTime? updatedAt,
    required DateTime? publishedAt,
    required String? summary,
    required String? description,
    required List<ClinicalHistoryDiagnosisEntity> diagnosis,
    required List<String> observations,
    required List<ClinicalHistoryAttachmentEntity> attachments,
    required ClinicalHistoryStateEntity? state,
  }) = _ClinicalHistoryEntity;
}
