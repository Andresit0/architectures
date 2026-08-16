import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/dtos/_dtos.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class AuthMapper {
  static LoginResponseEntity loginResponseFromDto(LoginResponseDto dto) =>
      LoginResponseEntity(
        patient: patientFromDto(dto.patient),
        token: tokenFromDto(dto.token),
        clinicalHistory: dto.clinicalHistory
            .map(clinicalHistoryFromDto)
            .toList(),
      );

  static TokenEntity tokenFromDto(TokenDto dto) =>
      TokenEntity(type: dto.type, key: dto.key);

  static PatientEntity patientFromDto(PatientDto dto) =>
      PatientEntity(id: dto.id, name: dto.name);

  static ClinicalHistoryEntity clinicalHistoryFromDto(ClinicalHistoryDto dto) =>
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
