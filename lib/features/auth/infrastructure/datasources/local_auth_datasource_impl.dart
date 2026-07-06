import '../../../../shared/database/_database.lib.dart';
import '../../../../shared/functions/_function.lib.dart';

import '../../domain/datasources/i_local_auth_datasource.dart';
import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/token_entity.dart';

class LocalAuthDatasourceImpl implements ILocalAuthDatasource {
  LocalAuthDatasourceImpl({
    required this._patientInfo,
    required this._clinicalHistory,
    required this._tokenService,
    required this._appDatabase,
    required this._internetService,
  });

  final IPatientInfoStore _patientInfo;
  final IClinicalHistoryStore _clinicalHistory;
  final ITokenService _tokenService;
  final AppDatabase _appDatabase;
  final IInternetService _internetService;

  @override
  Future<void> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async {
    await _patientInfo.save(data.patient);
    await _clinicalHistory.storeAll(data.clinicalHistory ?? []);
    await _tokenService.save(data.token.key);
    await _tokenService.saveCredentials(
      email: email,
      passwordHash: passwordHash,
    );
  }

  @override
  Future<void> clearSession() async {
    await _tokenService.deleteAll();
    await _appDatabase.resetDatabase();
  }

  @override
  Future<LoginResponseEntity?> restoreSession() async {
    final patient = await _patientInfo.load();
    final tokenStr = await _tokenService.read();
    if (patient == null || tokenStr == null) return null;
    if (await _tokenService.isTokenExpired(tokenStr)) {
      if (await _internetService.isConnected()) {
        await _tokenService.deleteAll();
        return null;
      }
    }
    final clinicalHistory = await _clinicalHistory.loadAll();
    return LoginResponseEntity(
      patient: patient,
      token: TokenEntity(
        type: 'Bearer',
        key: tokenStr,
        expiresInHours: 0,
        expirationDate: null,
      ),
      clinicalHistory: clinicalHistory.isEmpty ? null : clinicalHistory,
    );
  }
}
