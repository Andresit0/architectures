import 'package:clean_architecture_sdd_harness/core/database/serializers/lab_results_serializer.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_entity.dart';
import 'package:sembast/sembast.dart';

class LabResults implements ILabResultsStore {
  LabResults({required Future<Database> database}) : _db = database;
  final StoreRef<String, Map<String, Object?>> _store = stringMapStoreFactory
      .store('lab_results');
  final Future<Database> _db;

  @override
  Future<void> storeAll(List<LabResultEntity> entities) async {
    final db = await _db;
    await db.transaction((txn) async {
      await _store.delete(txn);
      for (final entity in entities) {
        await _store
            .record(entity.id)
            .put(txn, LabResultsSerializer.toMap(entity));
      }
    });
  }

  @override
  Future<List<LabResultEntity>> loadAll() async {
    final db = await _db;
    final records = await _store.find(db);
    return records.map((record) {
      return LabResultsSerializer.fromMap(
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
