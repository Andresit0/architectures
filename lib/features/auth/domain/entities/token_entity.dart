import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_entity.freezed.dart';

@freezed
abstract class TokenEntity with _$TokenEntity {
  const TokenEntity._();

  const factory TokenEntity({required String type, required String key}) =
      _TokenEntity;
}
