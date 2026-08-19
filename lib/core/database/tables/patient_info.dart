import 'package:clean_architecture_sdd_harness/core/database/serializers/patient_serializer.dart';
import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

class PatientInfo implements IPatientInfoStore {
  PatientInfo({required Future<IDatabaseHandle> database}) : _db = database;
  final Future<IDatabaseHandle> _db;
  static const _storeName = 'patient_info';
  static const _patientKey = 'patient';

  @override
  Future<void> save(PatientEntity patient) async {
    final db = await _db;
    await db.replaceAll(_storeName, {
      _patientKey: PatientSerializer.toMap(patient),
    });
  }

  @override
  Future<PatientEntity?> load() async {
    final db = await _db;
    final records = await db.findAll(_storeName);
    if (records.isEmpty) return null;
    return PatientSerializer.fromMap(Map<String, dynamic>.from(records.first));
  }

  @override
  Future<void> delete() async {
    final db = await _db;
    await db.deleteAll(_storeName);
  }
}
