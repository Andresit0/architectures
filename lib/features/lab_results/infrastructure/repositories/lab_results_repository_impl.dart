import 'package:clean_architecture_sdd_harness/core/repositories/online_first_repository.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import '../../domain/datasources/i_lab_results_local_datasource.dart';
import '../../domain/datasources/i_lab_results_remote_datasource.dart';
import '../../domain/repositories/i_lab_results_repository.dart';

class LabResultsRepositoryImpl extends OnlineFirstRepository<LabResultEntity>
    implements ILabResultsRepository {
  const LabResultsRepositoryImpl({
    required this._remoteDatasource,
    required this._localDatasource,
    required super.logger,
  }) : super(logTag: 'lab_results');

  final ILabResultsRemoteDatasource _remoteDatasource;
  final ILabResultsLocalDatasource _localDatasource;

  @override
  Future<List<LabResultEntity>> remoteLoader() =>
      _remoteDatasource.loadRemote();

  @override
  Future<List<LabResultEntity>?> localLoader() => _localDatasource.loadLocal();

  @override
  Future<void> cacheWriter(List<LabResultEntity> data) =>
      _localDatasource.storeLocal(data);

  @override
  Future<Result<List<LabResultEntity>>> loadLabResults() => load();

  @override
  Future<Result<List<LabResultEntity>>> refreshLabResults() => refresh();
}
