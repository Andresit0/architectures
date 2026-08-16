import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';

abstract interface class IClinicalHistoryReader {
  Future<List<ClinicalHistoryEntity>> loadAll();
}

abstract interface class IClinicalHistoryWriter {
  Future<void> storeAll(List<ClinicalHistoryEntity> entities);
  Future<void> deleteAll();
}

abstract interface class IClinicalHistoryStore
    implements IClinicalHistoryReader, IClinicalHistoryWriter {}
