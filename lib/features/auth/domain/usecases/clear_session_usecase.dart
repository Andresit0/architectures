import '../../../../shared/exceptions/_exceptions.lib.dart';
import '../repositories/i_auth_repository.dart';

class ClearSessionUseCase {
  const ClearSessionUseCase({required this._repository});

  final IAuthRepository _repository;

  Future<Either<Failure, void>> call() => _repository.clearSession();
}
