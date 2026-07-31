import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_credential_store.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_connectivity_checker.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_token_store.dart';
import '../repositories/i_auth_repository.dart';
import 'refresh_token_usecase.dart';
import '../value_objects/email.dart';
import '../value_objects/password_hash.dart';

class Handle401UseCase {
  const Handle401UseCase({
    required this._tokenStore,
    required this._connectivityChecker,
    required this._refreshTokenUseCase,
    required this._repository,
    required this._credentialStore,
  });

  final ITokenStore _tokenStore;
  final IConnectivityChecker _connectivityChecker;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final IAuthRepository _repository;
  final ICredentialStore _credentialStore;

  Future<Result<RetryResult>> call() async {
    if (!await _connectivityChecker.isConnected()) {
      return const Failure(NetworkError.technical());
    }

    final token = await _tokenStore.read();
    if (token != null) {
      final refreshResult = await _refreshTokenUseCase(token: token);
      if (refreshResult case Success(:final data)) {
        await _tokenStore.save(data.key);
        return Success(RetrySuccess(data.key));
      }

      final credentials = await _credentialStore.readCredentials();
      if (credentials != null) {
        final email = Email.tryCreate(credentials.email);
        final passwordHash = PasswordHash.tryCreate(credentials.passwordHash);
        if (email != null && passwordHash != null) {
          final loginResult = await _repository.login(
            email: email,
            passwordHash: passwordHash,
          );
          if (loginResult case Success(:final data)) {
            await _tokenStore.save(data.token.key);
            return Success(RetrySuccess(data.token.key));
          }
        }
      }
    }

    return const Failure(UnexpectedError.technical());
  }
}
