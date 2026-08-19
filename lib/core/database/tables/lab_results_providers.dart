import 'package:clean_architecture_sdd_harness/core/database/app_database_provider.dart';
import 'package:clean_architecture_sdd_harness/core/database/tables/lab_results.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final labResultsStoreProvider = Provider<ILabResultsStore>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return LabResults(database: appDb.database);
});
