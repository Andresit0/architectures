// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryDto _$ClinicalHistoryDtoFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryDto(
  id: json['id'] as String,
  encounterNumber: json['encounter_number'] as String,
  service: ClinicalHistoryServiceDto.fromJson(
    json['service'] as Map<String, dynamic>,
  ),
  facility: ClinicalHistoryFacilityDto.fromJson(
    json['facility'] as Map<String, dynamic>,
  ),
  professional: json['professional'] == null
      ? null
      : ClinicalHistoryProfessionalDto.fromJson(
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
  diagnosis:
      (json['diagnosis'] as List<dynamic>?)
          ?.map(
            (e) =>
                ClinicalHistoryDiagnosisDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  observations:
      (json['observations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map(
            (e) => ClinicalHistoryAttachmentDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
  state: json['state'] == null
      ? null
      : ClinicalHistoryStateDto.fromJson(json['state'] as Map<String, dynamic>),
);

abstract final class _$ClinicalHistoryDtoJsonKeys {
  static const String id = 'id';
  static const String encounterNumber = 'encounter_number';
  static const String service = 'service';
  static const String facility = 'facility';
  static const String professional = 'professional';
  static const String encounterDate = 'encounter_date';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String publishedAt = 'published_at';
  static const String summary = 'summary';
  static const String description = 'description';
  static const String diagnosis = 'diagnosis';
  static const String observations = 'observations';
  static const String attachments = 'attachments';
  static const String state = 'state';
}

Map<String, dynamic> _$ClinicalHistoryDtoToJson(_ClinicalHistoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'encounter_number': instance.encounterNumber,
      'service': instance.service.toJson(),
      'facility': instance.facility.toJson(),
      'professional': instance.professional?.toJson(),
      'encounter_date': instance.encounterDate,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'published_at': instance.publishedAt?.toIso8601String(),
      'summary': instance.summary,
      'description': instance.description,
      'diagnosis': instance.diagnosis.map((e) => e.toJson()).toList(),
      'observations': instance.observations,
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'state': instance.state?.toJson(),
    };
