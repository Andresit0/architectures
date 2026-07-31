// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_attachment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryAttachmentDto _$ClinicalHistoryAttachmentDtoFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryAttachmentDto(
  id: json['id'] as String,
  type: json['type'] as String,
  name: json['name'] as String,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  url: json['url'] as String,
);

abstract final class _$ClinicalHistoryAttachmentDtoJsonKeys {
  static const String id = 'id';
  static const String type = 'type';
  static const String name = 'name';
  static const String sizeBytes = 'size_bytes';
  static const String url = 'url';
}

Map<String, dynamic> _$ClinicalHistoryAttachmentDtoToJson(
  _ClinicalHistoryAttachmentDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'name': instance.name,
  'size_bytes': instance.sizeBytes,
  'url': instance.url,
};
