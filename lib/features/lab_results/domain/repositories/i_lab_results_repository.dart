import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

abstract interface class ILabResultsRepository {
  Future<Result<List<LabResultEntity>>> loadLabResults();

  Future<Result<List<LabResultEntity>>> refreshLabResults();
}
