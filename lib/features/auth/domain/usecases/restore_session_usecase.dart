import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_connectivity_checker.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_credential_store.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_token_verifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';

class RestoreSessionUseCase {
  const RestoreSessionUseCase({
    required this._repository,
    required this._connectivityChecker,
    required this._credentialStore,
    required this._tokenVerifier,
  });

  final IAuthRepository _repository;
  final IConnectivityChecker _connectivityChecker;
  final ICredentialStore _credentialStore;
  final ITokenVerifier _tokenVerifier;

  Future<Result<LoginResponseEntity?>> call() async {
    final online = await _connectivityChecker.isConnected();
    final credentials = await _credentialStore.readCredentials();

    if (online && credentials != null) {
      final email = Email.tryCreate(credentials.email);
      final passwordHash = PasswordHash.tryCreate(credentials.passwordHash);
      if (email != null && passwordHash != null) {
        final loginResult = await _repository.login(
          email: email,
          passwordHash: passwordHash,
        );
        if (loginResult case Success(data: final loginData)) {
          await _credentialStore.saveToken(loginData.token.key);
          return Success(loginData);
        }
      }
    }

    final localResult = await _repository.restoreSession();
    if (localResult case Failure()) return localResult;
    final localData = (localResult as Success<LoginResponseEntity?>).data;
    if (localData == null) return const Success(null);

    if (await _tokenVerifier.isExpired(localData.token.key) && online) {
      final refreshResult = await _repository.refreshToken(
        token: localData.token.key,
      );
      if (refreshResult case Success(data: final tokenData)) {
        await _credentialStore.saveToken(tokenData.key);
        return Success(
          localData.copyWith(
            token: TokenEntity(
              type: tokenData.type,
              key: tokenData.key,
            ),
          ),
        );
      } else {
        await _credentialStore.deleteAll();
        return const Success(null);
      }
    }

    return Success(localData);
  }
}
