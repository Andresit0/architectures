import 'package:clean_architecture_sdd_harness/core/database/serializers/patient_serializer.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:sembast/sembast.dart';

class PatientInfo implements IPatientInfoStore {
  PatientInfo({required Future<Database> database}) : _db = database;
  final StoreRef<int, Map<String, Object?>> _store = intMapStoreFactory.store(
    'patient_info',
  );
  final Future<Database> _db;

  @override
  Future<void> save(PatientEntity patient) async {
    final db = await _db;
    await db.transaction((txn) async {
      await _store.delete(txn);
      await _store.add(txn, PatientSerializer.toMap(patient));
    });
  }

  @override
  Future<PatientEntity?> load() async {
    final db = await _db;
    final records = await _store.find(db);
    if (records.isEmpty) return null;
    return PatientSerializer.fromMap(
      Map<String, dynamic>.from(records.first.value),
    );
  }

  @override
  Future<void> delete() async {
    final db = await _db;
    await _store.delete(db);
  }
}
