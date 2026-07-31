import 'package:freezed_annotation/freezed_annotation.dart';

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

  factory Password.create(String value) {
    final error = _validate(value);
    if (error != null) throw FormatException(error);
    return Password.raw(value);
  }

  static Password? tryCreate(String value) {
    final error = _validate(value);
    if (error != null) return null;
    return Password.raw(value);
  }
}
