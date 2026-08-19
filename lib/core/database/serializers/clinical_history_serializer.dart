import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_attachment_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_diagnosis_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_facility_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_professional_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_service_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_state_entity.dart';

class ClinicalHistorySerializer {
  static Map<String, dynamic> toMap(ClinicalHistoryEntity entity) => {
    'id': entity.id,
    'encounter_number': entity.encounterNumber,
    'service': _serviceToMap(entity.service),
    'facility': _facilityToMap(entity.facility),
    if (entity.professional != null)
      'professional': _professionalToMap(entity.professional!),
    'encounter_date': entity.encounterDate,
    if (entity.createdAt != null)
      'created_at': entity.createdAt!.toIso8601String(),
    if (entity.updatedAt != null)
      'updated_at': entity.updatedAt!.toIso8601String(),
    if (entity.publishedAt != null)
      'published_at': entity.publishedAt!.toIso8601String(),
    if (entity.summary != null) 'summary': entity.summary,
    if (entity.description != null) 'description': entity.description,
    'diagnosis': entity.diagnosis.map(_diagnosisToMap).toList(),
    'observations': entity.observations,
    'attachments': entity.attachments.map(_attachmentToMap).toList(),
    if (entity.state != null) 'state': _stateToMap(entity.state!),
  };

  static ClinicalHistoryEntity fromMap(Map<String, dynamic> map) =>
      ClinicalHistoryEntity(
        id: map['id'] as String,
        encounterNumber: map['encounter_number'] as String,
        service: _serviceFromMap(map['service'] as Map<String, dynamic>),
        facility: _facilityFromMap(map['facility'] as Map<String, dynamic>),
        professional: map['professional'] != null
            ? _professionalFromMap(map['professional'] as Map<String, dynamic>)
            : null,
        encounterDate: map['encounter_date'] as String,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
        publishedAt: map['published_at'] != null
            ? DateTime.parse(map['published_at'] as String)
            : null,
        summary: map['summary'] as String?,
        description: map['description'] as String?,
        diagnosis: (map['diagnosis'] as List<dynamic>)
            .map((e) => _diagnosisFromMap(e as Map<String, dynamic>))
            .toList(),
        observations: (map['observations'] as List<dynamic>).cast<String>(),
        attachments: (map['attachments'] as List<dynamic>)
            .map((e) => _attachmentFromMap(e as Map<String, dynamic>))
            .toList(),
        state: map['state'] != null
            ? _stateFromMap(map['state'] as Map<String, dynamic>)
            : null,
      );

  static Map<String, dynamic> _serviceToMap(ClinicalHistoryServiceEntity e) => {
    'code': e.code,
    'name': e.name,
    'category': e.category,
  };

  static ClinicalHistoryServiceEntity _serviceFromMap(Map<String, dynamic> m) =>
      ClinicalHistoryServiceEntity(
        code: m['code'] as String,
        name: m['name'] as String,
        category: m['category'] as String,
      );

  static Map<String, dynamic> _facilityToMap(ClinicalHistoryFacilityEntity e) =>
      {'id': e.id, 'name': e.name, 'city': e.city};

  static ClinicalHistoryFacilityEntity _facilityFromMap(
    Map<String, dynamic> m,
  ) => ClinicalHistoryFacilityEntity(
    id: m['id'] as String,
    name: m['name'] as String,
    city: m['city'] as String,
  );

  static Map<String, dynamic> _professionalToMap(
    ClinicalHistoryProfessionalEntity e,
  ) => {'id': e.id, 'fullname': e.fullname, 'specialty': e.specialty};

  static ClinicalHistoryProfessionalEntity _professionalFromMap(
    Map<String, dynamic> m,
  ) => ClinicalHistoryProfessionalEntity(
    id: m['id'] as String,
    fullname: m['fullname'] as String,
    specialty: m['specialty'] as String,
  );

  static Map<String, dynamic> _diagnosisToMap(
    ClinicalHistoryDiagnosisEntity e,
  ) => {'code': e.code, 'name': e.name};

  static ClinicalHistoryDiagnosisEntity _diagnosisFromMap(
    Map<String, dynamic> m,
  ) => ClinicalHistoryDiagnosisEntity(
    code: m['code'] as String,
    name: m['name'] as String,
  );

  static Map<String, dynamic> _attachmentToMap(
    ClinicalHistoryAttachmentEntity e,
  ) => {
    'id': e.id,
    'type': e.type,
    'name': e.name,
    'size_bytes': e.sizeBytes,
    'url': e.url,
  };

  static ClinicalHistoryAttachmentEntity _attachmentFromMap(
    Map<String, dynamic> m,
  ) => ClinicalHistoryAttachmentEntity(
    id: m['id'] as String,
    type: m['type'] as String,
    name: m['name'] as String,
    sizeBytes: m['size_bytes'] as int,
    url: m['url'] as String,
  );

  static Map<String, dynamic> _stateToMap(ClinicalHistoryStateEntity e) => {
    'code': e.code,
    'label': e.label,
  };

  static ClinicalHistoryStateEntity _stateFromMap(Map<String, dynamic> m) =>
      ClinicalHistoryStateEntity(
        code: m['code'] as String,
        label: m['label'] as String,
      );
}
