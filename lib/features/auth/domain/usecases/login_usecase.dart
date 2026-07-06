import '../../../../shared/exceptions/_exceptions.lib.dart';
import '../entities/login_response_entity.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  const LoginUseCase({required this._repository});

  final IAuthRepository _repository;

  Future<Either<Failure, LoginResponseEntity>> call({
    required String email,
    required String passwordHash,
  }) =>
      _repository.login(
        email: email,
        passwordHash: passwordHash,
      );
}
