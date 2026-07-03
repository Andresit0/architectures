part of '../_database.lib.dart';

abstract class IClinicalHistoryStore {
  Future<void> store(ClinicalHistoryEntity entity);
  Future<void> storeAll(List<ClinicalHistoryEntity> entities);
  Future<ClinicalHistoryEntity?> load(String id);
  Future<List<ClinicalHistoryEntity>> loadAll();
  Future<void> delete(String id);
  Future<void> deleteAll();
  Future<void> update(ClinicalHistoryEntity entity);
  Future<void> updateAll(List<ClinicalHistoryEntity> entities);
}

class ClinicalHistory implements IClinicalHistoryStore {
  final _store = intMapStoreFactory.store('clinical_histories');
  final Future<Database>? _database;

  ClinicalHistory({this._database});

  Future<Database> get _db => _database ?? AppDatabase().database;

  static Map<String, dynamic> _toMap(ClinicalHistoryEntity entity) =>
      jsonDecode(jsonEncode(entity)) as Map<String, dynamic>;

  @override
  Future<void> store(ClinicalHistoryEntity entity) async {
    final db = await _db;
    await delete(entity.id);
    await _store.add(db, _toMap(entity));
  }

  @override
  Future<void> storeAll(List<ClinicalHistoryEntity> entities) async {
    final db = await _db;
    await _store.delete(db);
    for (final entity in entities) {
      await _store.add(db, _toMap(entity));
    }
  }

  @override
  Future<ClinicalHistoryEntity?> load(String id) async {
    final db = await _db;
    final finder = Finder(filter: Filter.equals('id', id));
    final records = await _store.find(db, finder: finder);
    if (records.isEmpty) return null;
    return ClinicalHistoryEntity.fromJson(
      Map<String, dynamic>.from(records.first.value),
    );
  }

  @override
  Future<List<ClinicalHistoryEntity>> loadAll() async {
    final db = await _db;
    final records = await _store.find(db);
    return records.map((record) {
      return ClinicalHistoryEntity.fromJson(
        Map<String, dynamic>.from(record.value),
      );
    }).toList();
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    final finder = Finder(filter: Filter.equals('id', id));
    await _store.delete(db, finder: finder);
  }

  @override
  Future<void> deleteAll() async {
    final db = await _db;
    await _store.delete(db);
  }

  @override
  Future<void> update(ClinicalHistoryEntity entity) async {
    final db = await _db;
    final finder = Finder(filter: Filter.equals('id', entity.id));
    await _store.update(db, _toMap(entity), finder: finder);
  }

  @override
  Future<void> updateAll(List<ClinicalHistoryEntity> entities) async {
    final db = await _db;
    for (final entity in entities) {
      final finder = Finder(filter: Filter.equals('id', entity.id));
      await _store.update(db, _toMap(entity), finder: finder);
    }
  }
}
