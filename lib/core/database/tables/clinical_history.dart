import 'package:clean_architecture_sdd_harness/core/database/serializers/clinical_history_serializer.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';
import 'package:sembast/sembast.dart';

class ClinicalHistory implements IClinicalHistoryStore {
  ClinicalHistory({required Future<Database> database}) : _db = database;
  final StoreRef<String, Map<String, Object?>> _store = stringMapStoreFactory
      .store('clinical_histories');
  final Future<Database> _db;

  @override
  Future<void> storeAll(List<ClinicalHistoryEntity> entities) async {
    final db = await _db;
    await db.transaction((txn) async {
      await _store.delete(txn);
      for (final entity in entities) {
        await _store
            .record(entity.id)
            .put(txn, ClinicalHistorySerializer.toMap(entity));
      }
    });
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
  Future<void> deleteAll() async {
    final db = await _db;
    await _store.delete(db);
  }
}
