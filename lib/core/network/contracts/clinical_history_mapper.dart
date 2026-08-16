import 'package:clean_architecture_sdd_harness/core/network/contracts/clinical_history_attachment_dto.dart';
import 'package:clean_architecture_sdd_harness/core/network/contracts/clinical_history_diagnosis_dto.dart';
import 'package:clean_architecture_sdd_harness/core/network/contracts/clinical_history_dto.dart';
import 'package:clean_architecture_sdd_harness/core/network/contracts/clinical_history_facility_dto.dart';
import 'package:clean_architecture_sdd_harness/core/network/contracts/clinical_history_professional_dto.dart';
import 'package:clean_architecture_sdd_harness/core/network/contracts/clinical_history_service_dto.dart';
import 'package:clean_architecture_sdd_harness/core/network/contracts/clinical_history_state_dto.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class ClinicalHistoryMapper {
  static ClinicalHistoryEntity fromDto(ClinicalHistoryDto dto) =>
      ClinicalHistoryEntity(
        id: dto.id,
        encounterNumber: dto.encounterNumber,
        service: serviceFromDto(dto.service),
        facility: facilityFromDto(dto.facility),
        professional: dto.professional != null
            ? professionalFromDto(dto.professional!)
            : null,
        encounterDate: dto.encounterDate,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
        publishedAt: dto.publishedAt,
        summary: dto.summary,
        description: dto.description,
        diagnosis: dto.diagnosis.map(diagnosisFromDto).toList(),
        observations: dto.observations,
        attachments: dto.attachments.map(attachmentFromDto).toList(),
        state: dto.state != null ? stateFromDto(dto.state!) : null,
      );

  static List<ClinicalHistoryEntity> fromDtoList(
    List<ClinicalHistoryDto> list,
  ) => list.map(fromDto).toList();

  static ClinicalHistoryServiceEntity serviceFromDto(
    ClinicalHistoryServiceDto dto,
  ) => ClinicalHistoryServiceEntity(
    code: dto.code,
    name: dto.name,
    category: dto.category,
  );

  static ClinicalHistoryFacilityEntity facilityFromDto(
    ClinicalHistoryFacilityDto dto,
  ) =>
      ClinicalHistoryFacilityEntity(id: dto.id, name: dto.name, city: dto.city);

  static ClinicalHistoryProfessionalEntity professionalFromDto(
    ClinicalHistoryProfessionalDto dto,
  ) => ClinicalHistoryProfessionalEntity(
    id: dto.id,
    fullname: dto.fullname,
    specialty: dto.specialty,
  );

  static ClinicalHistoryDiagnosisEntity diagnosisFromDto(
    ClinicalHistoryDiagnosisDto dto,
  ) => ClinicalHistoryDiagnosisEntity(code: dto.code, name: dto.name);

  static ClinicalHistoryAttachmentEntity attachmentFromDto(
    ClinicalHistoryAttachmentDto dto,
  ) => ClinicalHistoryAttachmentEntity(
    id: dto.id,
    type: dto.type,
    name: dto.name,
    sizeBytes: dto.sizeBytes,
    url: dto.url,
  );

  static ClinicalHistoryStateEntity stateFromDto(ClinicalHistoryStateDto dto) =>
      ClinicalHistoryStateEntity(code: dto.code, label: dto.label);
}
