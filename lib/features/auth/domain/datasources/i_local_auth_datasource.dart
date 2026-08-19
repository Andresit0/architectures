import '../../domain/entities/login_response_entity.dart';

abstract interface class ILocalAuthDatasource {
  Future<void> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  });

  Future<void> clearSession();

  Future<LoginResponseEntity?> restoreSession();

  Future<void> resetAccount();
}
