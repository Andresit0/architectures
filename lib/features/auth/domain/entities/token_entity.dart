import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_entity.freezed.dart';
part 'token_entity.g.dart';

@freezed
abstract class TokenEntity with _$TokenEntity {
  const TokenEntity._();

  const factory TokenEntity({
    required String type,
    required String key,
    @JsonKey(name: 'expires_in_hours') required int expiresInHours,
    @JsonKey(name: 'expiration_date') required DateTime? expirationDate,
  }) = _TokenEntity;

  factory TokenEntity.fromJson(Map<String, dynamic> json) =>
      _$TokenEntityFromJson(json);
}
