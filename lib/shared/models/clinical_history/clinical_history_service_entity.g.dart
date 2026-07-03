// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_history_service_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClinicalHistoryServiceEntity _$ClinicalHistoryServiceEntityFromJson(
  Map<String, dynamic> json,
) => _ClinicalHistoryServiceEntity(
  code: json['code'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
);

Map<String, dynamic> _$ClinicalHistoryServiceEntityToJson(
  _ClinicalHistoryServiceEntity instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'category': instance.category,
};
