part of '../_database.lib.dart';

abstract class IPatientInfoStore {
  Future<void> save(PatientEntity patient);
  Future<PatientEntity?> load();
  Future<void> delete();
}

class PatientInfo implements IPatientInfoStore {
  final _store = intMapStoreFactory.store('patient_info');
  final Future<Database>? _database;

  PatientInfo({this._database});

  Future<Database> get _db => _database ?? AppDatabase().database;

  static Map<String, dynamic> _toMap(PatientEntity entity) =>
      jsonDecode(jsonEncode(entity)) as Map<String, dynamic>;

  @override
  Future<void> save(PatientEntity patient) async {
    final db = await _db;
    await _store.delete(db);
    await _store.add(db, _toMap(patient));
  }

  @override
  Future<PatientEntity?> load() async {
    final db = await _db;
    final records = await _store.find(db);
    if (records.isEmpty) return null;
    return PatientEntity.fromJson(
      Map<String, dynamic>.from(records.first.value),
    );
  }

  @override
  Future<void> delete() async {
    final db = await _db;
    await _store.delete(db);
  }
}
