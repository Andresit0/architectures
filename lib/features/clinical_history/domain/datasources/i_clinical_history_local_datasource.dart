import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

abstract interface class IClinicalHistoryLocalDatasource {
  Future<List<ClinicalHistoryEntity>> loadLocal();

  Future<void> storeLocal(List<ClinicalHistoryEntity> entities);
}
