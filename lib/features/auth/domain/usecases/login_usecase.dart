import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'login_input.dart';

class LoginUseCase implements IUseCase<LoginInput, LoginResponseEntity> {
  const LoginUseCase({
    required this._repository,
    required this._sessionRepository,
    required this._passwordHasher,
    required this._tokenStore,
  });

  final IAuthRepository _repository;
  final ILocalAuthRepository _sessionRepository;
  final IPasswordHasher _passwordHasher;
  final ITokenStore _tokenStore;

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
        if (input.rememberMe) {
          final saveResult = await _sessionRepository.saveSession(
            data: data,
            email: validatedEmail,
            passwordHash: validatedPasswordHash,
          );
          if (saveResult is Failure) {
            return Failure(saveResult.error);
          }
        } else {
          final saveTokenResult = await guard(
            () => _tokenStore.save(data.token.key),
          );
          if (saveTokenResult is Failure) {
            return Failure(saveTokenResult.error);
          }
        }
        return Success(data);
      case Failure():
        return loginResult;
    }
  }
}
