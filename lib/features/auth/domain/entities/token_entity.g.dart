// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenEntity _$TokenEntityFromJson(Map<String, dynamic> json) => _TokenEntity(
  type: json['type'] as String,
  key: json['key'] as String,
  expiresInHours: (json['expires_in_hours'] as num).toInt(),
  expirationDate: json['expiration_date'] == null
      ? null
      : DateTime.parse(json['expiration_date'] as String),
);

Map<String, dynamic> _$TokenEntityToJson(_TokenEntity instance) =>
    <String, dynamic>{
      'type': instance.type,
      'key': instance.key,
      'expires_in_hours': instance.expiresInHours,
      'expiration_date': instance.expirationDate?.toIso8601String(),
    };
