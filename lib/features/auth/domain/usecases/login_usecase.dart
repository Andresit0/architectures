import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_password_hasher.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_token_store.dart';

class LoginUseCase {
  const LoginUseCase({
    required this._repository,
    required this._passwordHasher,
    required this._tokenStore,
  });

  final IAuthRepository _repository;
  final IPasswordHasher _passwordHasher;
  final ITokenStore _tokenStore;

  Future<Result<LoginResponseEntity>> call({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final emailResult = _createEmail(email);
    if (emailResult case Failure(:final error)) {
      return Failure(error);
    }
    final passwordResult = _createPassword(password);
    if (passwordResult case Failure(:final error)) {
      return Failure(error);
    }
    final hash = await _passwordHasher.hash(password);
    final hashResult = _createPasswordHash(hash);
    if (hashResult case Failure(:final error)) {
      return Failure(error);
    }
    final loginResult = await _repository.login(
      email: (emailResult as Success<Email>).data,
      passwordHash: (hashResult as Success<PasswordHash>).data,
    );
    if (rememberMe) {
      switch (loginResult) {
        case Success(:final data):
          final saveResult = await _repository.saveSession(
            data: data,
            email: email,
            passwordHash: hash,
          );
          if (saveResult is Failure) {
            return Failure(saveResult.error);
          }
        case Failure():
          return loginResult;
      }
    }

    switch (loginResult) {
      case Success(:final data):
        await _tokenStore.save(data.token.key);
        return Success(data);
      case Failure():
        return loginResult;
    }
  }

  Result<Email> _createEmail(String value) {
    try {
      return Success(Email.create(value));
    } on FormatException catch (e) {
      return Failure(ValidationError(e.message, field: 'email'));
    }
  }

  Result<Password> _createPassword(String value) {
    try {
      return Success(Password.create(value));
    } on FormatException catch (e) {
      return Failure(ValidationError(e.message, field: 'password'));
    }
  }

  Result<PasswordHash> _createPasswordHash(String value) {
    try {
      return Success(PasswordHash.create(value));
    } on FormatException catch (e) {
      return Failure(ValidationError(e.message));
    }
  }
}
