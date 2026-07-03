import '../../../../shared/exceptions/_exceptions.lib.dart';
import '../entities/login_response_entity.dart';
import '../repositories/i_auth_repository.dart';

class SaveSessionUseCase {
  const SaveSessionUseCase({required this._repository});

  final IAuthRepository _repository;

  Future<Either<Failure, void>> call({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) =>
      _repository.saveSession(
        data: data,
        email: email,
        passwordHash: passwordHash,
      );
}
