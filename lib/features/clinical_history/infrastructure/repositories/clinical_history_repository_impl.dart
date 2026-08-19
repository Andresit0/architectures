import 'package:clean_architecture_sdd_harness/core/repositories/online_first_repository.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import '../../domain/datasources/i_clinical_history_local_datasource.dart';
import '../../domain/datasources/i_clinical_history_remote_datasource.dart';
import '../../domain/repositories/i_clinical_history_repository.dart';

class ClinicalHistoryRepositoryImpl
    extends OnlineFirstRepository<ClinicalHistoryEntity>
    implements IClinicalHistoryRepository {
  const ClinicalHistoryRepositoryImpl({
    required this._remoteDatasource,
    required this._localDatasource,
    required super.logger,
  }) : super(logTag: 'clinical_history');

  final IClinicalHistoryRemoteDatasource _remoteDatasource;
  final IClinicalHistoryLocalDatasource _localDatasource;

  @override
  Future<List<ClinicalHistoryEntity>> remoteLoader() =>
      _remoteDatasource.loadRemote();

  @override
  Future<List<ClinicalHistoryEntity>?> localLoader() =>
      _localDatasource.loadLocal();

  @override
  Future<void> cacheWriter(List<ClinicalHistoryEntity> data) =>
      _localDatasource.storeLocal(data);

  @override
  Future<Result<List<ClinicalHistoryEntity>>> loadClinicalHistories() => load();

  @override
  Future<Result<List<ClinicalHistoryEntity>>> refreshClinicalHistories() =>
      refresh();
}
