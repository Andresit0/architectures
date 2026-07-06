part of '_database.lib.dart';

class CustomDb {
  static IClinicalHistoryStore clinicalHistory = ClinicalHistory();
  static IPatientInfoStore patientInfo = PatientInfo();
  static Future<void> resetDatabase() => AppDatabase().resetDatabase();
}
