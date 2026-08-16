import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';

class ClearSessionUseCase implements IUseCase<NoParams, void> {
  const ClearSessionUseCase({required this._repository});

  final ILocalAuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams input) async {
    final result = await _repository.clearSession();
    return result;
  }
}
