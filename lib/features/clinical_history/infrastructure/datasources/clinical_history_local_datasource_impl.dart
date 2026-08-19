import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import '../../domain/datasources/i_clinical_history_local_datasource.dart';

class ClinicalHistoryLocalDatasourceImpl
    implements IClinicalHistoryLocalDatasource {
  const ClinicalHistoryLocalDatasourceImpl({required this._store});

  final IClinicalHistoryStore _store;

  @override
  Future<List<ClinicalHistoryEntity>> loadLocal() => _store.loadAll();

  @override
  Future<void> storeLocal(List<ClinicalHistoryEntity> entities) =>
      _store.storeAll(entities);
}
