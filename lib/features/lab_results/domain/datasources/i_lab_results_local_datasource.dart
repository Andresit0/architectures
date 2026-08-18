import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

abstract interface class ILabResultsLocalDatasource {
  Future<List<LabResultEntity>> loadLocal();

  Future<void> storeLocal(List<LabResultEntity> entities);
}
