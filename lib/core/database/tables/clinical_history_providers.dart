import 'package:clean_architecture_sdd_harness/core/database/app_database_provider.dart';
import 'package:clean_architecture_sdd_harness/core/database/tables/clinical_history.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clinicalHistoryStoreProvider = Provider<IClinicalHistoryStore>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return ClinicalHistory(database: appDb.database.then((isDb) => isDb.db));
});
