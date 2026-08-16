import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import '../repositories/i_auth_repository.dart';

class ClearSessionUseCase {
  const ClearSessionUseCase({required this._repository});

  final IAuthRepository _repository;

  Future<Result<void>> call() async {
    final result = await _repository.clearSession();
    return result;
  }
}
