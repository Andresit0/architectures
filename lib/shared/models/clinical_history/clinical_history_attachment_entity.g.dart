// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_history_attachment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryAttachmentEntity _$ClinicalHistoryAttachmentEntityFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryAttachmentEntity(
  id: json['id'] as String,
  type: json['type'] as String,
  name: json['name'] as String,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  url: json['url'] as String,
);

Map<String, dynamic> _$ClinicalHistoryAttachmentEntityToJson(
  _ClinicalHistoryAttachmentEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'name': instance.name,
  'size_bytes': instance.sizeBytes,
  'url': instance.url,
};
