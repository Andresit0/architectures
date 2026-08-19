import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'login_input.dart';
import 'save_session_input.dart';

class LoginUseCase implements IUseCase<LoginInput, LoginResponseEntity> {
  const LoginUseCase({
    required this._repository,
    required this._passwordHasher,
    required this._saveSessionUseCase,
  });

  final IAuthRepository _repository;
  final IPasswordHasher _passwordHasher;
  final IUseCase<SaveSessionInput, void> _saveSessionUseCase;

  @override
  Future<Result<LoginResponseEntity>> call(LoginInput input) async {
    final emailResult = Email.result(input.email);
    if (emailResult case Failure(:final error)) {
      return Failure(error);
    }
    final passwordResult = Password.result(input.password);
    if (passwordResult case Failure(:final error)) {
      return Failure(error);
    }
    final validatedPassword = (passwordResult as Success<Password>).data;
    final hashResult = await guard(
      () => _passwordHasher.hash(validatedPassword.value),
    );
    if (hashResult case Failure(:final error)) {
      return Failure(error);
    }
    final hash = (hashResult as Success<String>).data;
    final passwordHashResult = PasswordHash.result(hash);
    if (passwordHashResult case Failure(:final error)) {
      return Failure(error);
    }
    final validatedEmail = (emailResult as Success<Email>).data;
    final validatedPasswordHash =
        (passwordHashResult as Success<PasswordHash>).data;
    final loginResult = await _repository.login(
      email: validatedEmail,
      passwordHash: validatedPasswordHash,
    );
    switch (loginResult) {
      case Success(:final data):
        final saveResult = await _saveSessionUseCase(
          SaveSessionInput(
            data: data,
            email: validatedEmail,
            passwordHash: validatedPasswordHash,
            rememberMe: input.rememberMe,
          ),
        );
        if (saveResult is Failure) {
          return Failure(saveResult.error);
        }
        return Success(data);
      case Failure():
        return loginResult;
    }
  }
}
