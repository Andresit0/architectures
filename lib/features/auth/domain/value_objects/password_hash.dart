import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_hash.freezed.dart';

@freezed
abstract class PasswordHash with _$PasswordHash {
  const PasswordHash._();
  const factory PasswordHash.raw(String value) = _PasswordHash;

  static String? _validate(String value) {
    if (value.isEmpty) return 'Password hash cannot be empty';
    return null;
  }

  factory PasswordHash.create(String value) {
    final error = _validate(value);
    if (error != null) throw FormatException(error);
    return PasswordHash.raw(value);
  }

  static PasswordHash? tryCreate(String value) {
    final error = _validate(value);
    if (error != null) return null;
    return PasswordHash.raw(value);
  }
}
