import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:sembast/sembast.dart';

class SembastDbWrapper implements IDatabaseHandle {
  SembastDbWrapper(this.db);

  final Database db;

  @override
  Future<List<Map<String, Object?>>> findAll(String store) async {
    final records = await _store(store).find(db);
    return records.map((r) => r.value).toList();
  }

  @override
  Future<void> replaceAll(
    String store,
    Map<String, Map<String, Object?>> records,
  ) async {
    await db.transaction((txn) async {
      final ref = _store(store);
      await ref.delete(txn);
      for (final entry in records.entries) {
        await ref.record(entry.key).put(txn, entry.value);
      }
    });
  }

  @override
  Future<void> deleteAll(String store) async {
    await _store(store).delete(db);
  }

  StoreRef<String, Map<String, Object?>> _store(String store) =>
      stringMapStoreFactory.store(store);
}
