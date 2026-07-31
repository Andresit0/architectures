import 'package:freezed_annotation/freezed_annotation.dart';

part 'email.freezed.dart';

@freezed
abstract class Email with _$Email {
  const Email._();
  const factory Email.raw(String value) = _Email;

  static String? _validate(String value) {
    if (value.isEmpty) return 'Email cannot be empty';
    if (!value.contains('@')) return 'Email must contain @';
    return null;
  }

  factory Email.create(String value) {
    final error = _validate(value);
    if (error != null) throw FormatException(error);
    return Email.raw(value);
  }

  static Email? tryCreate(String value) {
    final error = _validate(value);
    if (error != null) return null;
    return Email.raw(value);
  }
}
