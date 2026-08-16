import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

abstract interface class IClinicalHistoryRemoteDatasource {
  Future<List<ClinicalHistoryEntity>> loadRemote();
}
