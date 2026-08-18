import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_entity.dart';

abstract interface class ILabResultsReader {
  Future<List<LabResultEntity>> loadAll();
}

abstract interface class ILabResultsWriter {
  Future<void> storeAll(List<LabResultEntity> entities);
  Future<void> deleteAll();
}

abstract interface class ILabResultsStore
    implements ILabResultsReader, ILabResultsWriter {}
