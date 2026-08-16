import '../../../../core/database/_database.lib.dart';
import '../../../../core/network/connectivity/internet_service.dart';
import '../../../../shared/interfaces/_interfaces.lib.dart';

import '../../domain/datasources/i_local_auth_datasource.dart';
import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/token_entity.dart';

class LocalAuthDatasourceImpl implements ILocalAuthDatasource {
  LocalAuthDatasourceImpl({
    required this._patientInfo,
    required this._clinicalHistory,
    required this._tokenStore,
    required this._credentialStore,
    required this._tokenVerifier,
    required this._appDatabase,
    required this._internetService,
  });

  final IPatientInfoStore _patientInfo;
  final IClinicalHistoryStore _clinicalHistory;
  final ITokenStore _tokenStore;
  final ICredentialStore _credentialStore;
  final ITokenVerifier _tokenVerifier;
  final IAppDatabase _appDatabase;
  final IInternetService _internetService;

  @override
  Future<void> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async {
    await _patientInfo.save(data.patient);
    await _clinicalHistory.storeAll(data.clinicalHistory);
    await _tokenStore.save(data.token.key);
    await _credentialStore.saveCredentials(
      email: email,
      passwordHash: passwordHash,
    );
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([_tokenStore.delete(), _credentialStore.deleteAll()]);
    await _appDatabase.resetDatabase();
  }

  @override
  Future<LoginResponseEntity?> restoreSession() async {
    final patient = await _patientInfo.load();
    final tokenStr = await _tokenStore.read();
    if (patient == null || tokenStr == null) return null;
    if (await _tokenVerifier.isExpired(tokenStr)) {
      if (await _internetService.isConnected()) {
        await Future.wait([_tokenStore.delete(), _credentialStore.deleteAll()]);
        return null;
      }
    }
    final clinicalHistory = await _clinicalHistory.loadAll();
    return LoginResponseEntity(
      patient: patient,
      token: TokenEntity(type: 'Bearer', key: tokenStr),
      clinicalHistory: clinicalHistory,
    );
  }
}
