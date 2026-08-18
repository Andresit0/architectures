import 'package:clean_architecture_sdd_harness/core/database/app_database_provider.dart';
import 'package:clean_architecture_sdd_harness/core/database/tables/patient_info.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientInfoStoreProvider = Provider<IPatientInfoStore>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return PatientInfo(database: appDb.database);
});
