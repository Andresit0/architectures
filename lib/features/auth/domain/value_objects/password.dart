import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

part 'password.freezed.dart';

@freezed
abstract class Password with _$Password {
  const Password._();
  const factory Password.raw(String value) = _Password;

  static String? _validate(String value) {
    if (value.isEmpty) return 'Password cannot be empty';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static Result<Password> result(String value) {
    final error = _validate(value);
    if (error != null) {
      return Failure(ValidationError(field: 'password'));
    }
    return Success(Password.raw(value));
  }
}
