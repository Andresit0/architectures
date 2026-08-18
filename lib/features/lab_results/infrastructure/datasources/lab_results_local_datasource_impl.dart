import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import '../../domain/datasources/i_lab_results_local_datasource.dart';

class LabResultsLocalDatasourceImpl implements ILabResultsLocalDatasource {
  const LabResultsLocalDatasourceImpl({required this._store});

  final ILabResultsStore _store;

  @override
  Future<List<LabResultEntity>> loadLocal() => _store.loadAll();

  @override
  Future<void> storeLocal(List<LabResultEntity> entities) =>
      _store.storeAll(entities);
}
