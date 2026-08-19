import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_local_auth_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';

class LocalAuthDatasourceImpl implements ILocalAuthDatasource {
  LocalAuthDatasourceImpl({
    required this._patientInfo,
    required this._clinicalHistoryReader,
    required this._clinicalHistoryWriter,
    required this._tokenStore,
    required this._credentialStore,
    required this._appDatabase,
  });

  final IPatientInfoStore _patientInfo;
  final IClinicalHistoryReader _clinicalHistoryReader;
  final IClinicalHistoryWriter _clinicalHistoryWriter;
  final ITokenStore _tokenStore;
  final ICredentialStore _credentialStore;
  final IAppDatabase _appDatabase;

  @override
  Future<void> saveSession({
    required LoginResponseEntity data,
    required String email,
    required String passwordHash,
  }) async {
    await _patientInfo.save(data.patient);
    await _clinicalHistoryWriter.storeAll(data.clinicalHistory);
    await _tokenStore.save(data.token.key);
    await _credentialStore.saveCredentials(
      email: email,
      passwordHash: passwordHash,
    );
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _tokenStore.delete(),
      _credentialStore.deleteCredentials(),
      _patientInfo.delete(),
      _clinicalHistoryWriter.deleteAll(),
    ]);
  }

  @override
  Future<void> resetAccount() async {
    await clearSession();
    await _appDatabase.resetDatabase();
  }

  @override
  Future<LoginResponseEntity?> restoreSession() async {
    final patient = await _patientInfo.load();
    final tokenStr = await _tokenStore.read();
    if (patient == null || tokenStr == null) return null;
    final clinicalHistory = await _clinicalHistoryReader.loadAll();
    return LoginResponseEntity(
      patient: patient,
      token: TokenEntity(key: tokenStr),
      clinicalHistory: clinicalHistory,
    );
  }
}
