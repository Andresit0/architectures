import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

part 'password_hash.freezed.dart';

@freezed
abstract class PasswordHash with _$PasswordHash {
  const PasswordHash._();
  const factory PasswordHash.raw(String value) = _PasswordHash;

  static String? _validate(String value) {
    if (value.isEmpty) return 'PasswordHash cannot be empty';
    return null;
  }

  static Result<PasswordHash> result(String value) {
    final error = _validate(value);
    if (error != null) return Failure(ValidationError());
    return Success(PasswordHash.raw(value));
  }
}
