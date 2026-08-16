import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

abstract interface class IPatientInfoStore {
  Future<void> save(PatientEntity patient);
  Future<PatientEntity?> load();
  Future<void> delete();
}
