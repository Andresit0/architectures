import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

abstract interface class IClinicalHistoryRepository {
  Future<Result<List<ClinicalHistoryEntity>>> loadClinicalHistories();

  Future<Result<List<ClinicalHistoryEntity>>> refreshClinicalHistories();
}
