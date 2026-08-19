import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'save_session_input.dart';

class SaveSessionUseCase implements IUseCase<SaveSessionInput, void> {
  const SaveSessionUseCase({
    required this._sessionRepository,
    required this._tokenStore,
  });

  final ILocalAuthRepository _sessionRepository;
  final ITokenStore _tokenStore;

  @override
  Future<Result<void>> call(SaveSessionInput input) async {
    if (input.rememberMe) {
      return _sessionRepository.saveSession(
        data: input.data,
        email: input.email,
        passwordHash: input.passwordHash,
      );
    }
    return guard(() => _tokenStore.save(input.data.token.key));
  }
}
