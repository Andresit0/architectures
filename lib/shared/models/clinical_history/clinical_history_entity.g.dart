// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_history_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryEntity _$ClinicalHistoryEntityFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryEntity(
  id: json['id'] as String,
  encounterNumber: json['encounter_number'] as String,
  service: ClinicalHistoryServiceEntity.fromJson(
    json['service'] as Map<String, dynamic>,
  ),
  facility: ClinicalHistoryFacilityEntity.fromJson(
    json['facility'] as Map<String, dynamic>,
  ),
  professional: json['professional'] == null
      ? null
      : ClinicalHistoryProfessionalEntity.fromJson(
          json['professional'] as Map<String, dynamic>,
        ),
  encounterDate: json['encounter_date'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  summary: json['summary'] as String?,
  description: json['description'] as String?,
  diagnosis: (json['diagnosis'] as List<dynamic>)
      .map(
        (e) =>
            ClinicalHistoryDiagnosisEntity.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  observations: (json['observations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  attachments: (json['attachments'] as List<dynamic>)
      .map(
        (e) =>
            ClinicalHistoryAttachmentEntity.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  state: json['state'] == null
      ? null
      : ClinicalHistoryStateEntity.fromJson(
          json['state'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ClinicalHistoryEntityToJson(
  _ClinicalHistoryEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'encounter_number': instance.encounterNumber,
  'service': instance.service,
  'facility': instance.facility,
  'professional': instance.professional,
  'encounter_date': instance.encounterDate,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'published_at': instance.publishedAt?.toIso8601String(),
  'summary': instance.summary,
  'description': instance.description,
  'diagnosis': instance.diagnosis,
  'observations': instance.observations,
  'attachments': instance.attachments,
  'state': instance.state,
};
