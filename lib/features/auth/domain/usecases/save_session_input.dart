import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';

class SaveSessionInput {
  const SaveSessionInput({
    required this.data,
    required this.email,
    required this.passwordHash,
    required this.rememberMe,
  });

  final LoginResponseEntity data;
  final Email email;
  final PasswordHash passwordHash;
  final bool rememberMe;
}
