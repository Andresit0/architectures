import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';

class CredentialLoginUseCase
    implements IUseCase<NoParams, LoginResponseEntity?> {
  const CredentialLoginUseCase({
    required this._repository,
    required this._credentialStore,
    required this._logger,
  });

  final IAuthRepository _repository;
  final ICredentialStore _credentialStore;
  final ILogger _logger;

  @override
  Future<Result<LoginResponseEntity?>> call(NoParams input) async {
    final credentialsResult = await guard(
      () => _credentialStore.readCredentials(),
    );
    if (credentialsResult case Failure(:final error)) {
      return Failure(error);
    }
    final credentials =
        (credentialsResult as Success<({String email, String passwordHash})?>)
            .data;
    if (credentials == null) return const Success(null);
    final emailResult = Email.result(credentials.email);
    final passwordHashResult = PasswordHash.result(credentials.passwordHash);
    if (emailResult is Failure || passwordHashResult is Failure) {
      _logger.error(
        '[auth] stored credentials failed validation',
        technicalMessage: emailResult is Failure
            ? 'invalid email'
            : 'invalid passwordHash',
      );
      return const Success(null);
    }
    final email = (emailResult as Success<Email>).data;
    final passwordHash = (passwordHashResult as Success<PasswordHash>).data;
    switch (await _repository.login(email: email, passwordHash: passwordHash)) {
      case Success(data: final data):
        return Success<LoginResponseEntity?>(data);
      case Failure(:final error):
        return Failure<LoginResponseEntity?>(error);
    }
  }
}
