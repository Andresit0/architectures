import 'package:clean_architecture_sdd_harness/core/database/app_database_provider.dart';
import 'package:clean_architecture_sdd_harness/core/database/serializers/clinical_history_serializer.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

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
  ClinicalHistory({required Future<Database> database}) : _db = database;
  final StoreRef<int, Map<String, Object?>> _store = intMapStoreFactory.store(
    'clinical_histories',
  );
  final Future<Database> _db;

  @override
  Future<void> store(ClinicalHistoryEntity entity) async {
    final db = await _db;
    await delete(entity.id);
    await _store.add(db, ClinicalHistorySerializer.toMap(entity));
  }

  @override
  Future<void> storeAll(List<ClinicalHistoryEntity> entities) async {
    final db = await _db;
    await _store.delete(db);
    for (final entity in entities) {
      await _store.add(db, ClinicalHistorySerializer.toMap(entity));
    }
  }

  @override
  Future<ClinicalHistoryEntity?> load(String id) async {
    final db = await _db;
    final finder = Finder(filter: Filter.equals('id', id));
    final records = await _store.find(db, finder: finder);
    if (records.isEmpty) return null;
    return ClinicalHistorySerializer.fromMap(
      Map<String, dynamic>.from(records.first.value),
    );
  }

  @override
  Future<List<ClinicalHistoryEntity>> loadAll() async {
    final db = await _db;
    final records = await _store.find(db);
    return records.map((record) {
      return ClinicalHistorySerializer.fromMap(
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
    await _store.update(
      db,
      ClinicalHistorySerializer.toMap(entity),
      finder: finder,
    );
  }

  @override
  Future<void> updateAll(List<ClinicalHistoryEntity> entities) async {
    final db = await _db;
    for (final entity in entities) {
      final finder = Finder(filter: Filter.equals('id', entity.id));
      await _store.update(
        db,
        ClinicalHistorySerializer.toMap(entity),
        finder: finder,
      );
    }
  }
}

final clinicalHistoryStoreProvider = Provider<IClinicalHistoryStore>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return ClinicalHistory(database: appDb.database.then((isDb) => isDb.db));
});
