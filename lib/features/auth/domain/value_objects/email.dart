import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

part 'email.freezed.dart';

@freezed
abstract class Email with _$Email {
  const Email._();
  const factory Email.raw(String value) = _Email;

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static String? _validate(String value) {
    if (value.isEmpty) return 'Email cannot be empty';
    if (!_emailRegExp.hasMatch(value)) return 'Email must be a valid address';
    return null;
  }

  static Result<Email> result(String value) {
    final error = _validate(value);
    if (error != null) return Failure(ValidationError(field: 'email'));
    return Success(Email.raw(value));
  }
}
