import 'package:clean_architecture_sdd_harness/core/database/app_database_provider.dart';
import 'package:clean_architecture_sdd_harness/core/database/serializers/patient_serializer.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

abstract class IPatientInfoStore {
  Future<void> save(PatientEntity patient);
  Future<PatientEntity?> load();
  Future<void> delete();
}

class PatientInfo implements IPatientInfoStore {
  PatientInfo({required Future<Database> database}) : _db = database;
  final StoreRef<int, Map<String, Object?>> _store = intMapStoreFactory.store(
    'patient_info',
  );
  final Future<Database> _db;

  @override
  Future<void> save(PatientEntity patient) async {
    final db = await _db;
    await _store.delete(db);
    await _store.add(db, PatientSerializer.toMap(patient));
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

final patientInfoStoreProvider = Provider<IPatientInfoStore>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return PatientInfo(database: appDb.database.then((isDb) => isDb.db));
});
