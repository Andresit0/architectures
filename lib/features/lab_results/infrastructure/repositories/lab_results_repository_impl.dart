import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/online_first.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import '../../domain/datasources/i_lab_results_local_datasource.dart';
import '../../domain/datasources/i_lab_results_remote_datasource.dart';
import '../../domain/repositories/i_lab_results_repository.dart';

class LabResultsRepositoryImpl implements ILabResultsRepository {
  const LabResultsRepositoryImpl({
    required this._remoteDatasource,
    required this._localDatasource,
    required this._logger,
  });

  final ILabResultsRemoteDatasource _remoteDatasource;
  final ILabResultsLocalDatasource _localDatasource;
  final ILogger _logger;

  @override
  Future<Result<List<LabResultEntity>>> loadLabResults() async {
    final r = await fetchOrFallback(
      remote: _remoteDatasource.loadRemote,
      local: () async {
        final data = await _localDatasource.loadLocal();
        return data.isEmpty ? null : data;
      },
      onRemoteSuccess: (list) => _storeCache(list, 'load'),
    );
    _logger.info('[lab_results] load origin=${r.origin.name}');
    return r.result;
  }

  @override
  Future<Result<List<LabResultEntity>>> refreshLabResults() async {
    final result = await guard(() async {
      final list = await _remoteDatasource.loadRemote();
      await _storeCache(list, 'refresh');
      return list;
    });
    _logger.info('[lab_results] refresh origin=remote');
    return result;
  }

  Future<void> _storeCache(List<LabResultEntity> list, String context) async {
    try {
      await _localDatasource.storeLocal(list);
    } on Exception catch (e, st) {
      _logger.error(
        '[lab_results] cache write failed ($context)',
        technicalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }
}
