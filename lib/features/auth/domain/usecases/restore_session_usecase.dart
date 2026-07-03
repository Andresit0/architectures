import '../../../../shared/exceptions/_exceptions.lib.dart';
import '../entities/login_response_entity.dart';
import '../repositories/i_auth_repository.dart';

class RestoreSessionUseCase {
  const RestoreSessionUseCase({required this._repository});

  final IAuthRepository _repository;

  Future<Either<Failure, LoginResponseEntity?>> call() =>
      _repository.restoreSession();
}
