import 'package:clean_architecture_sdd_harness/core/database/serializers/clinical_history_serializer.dart';
import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/clinical_history/clinical_history_entity.dart';

class ClinicalHistory implements IClinicalHistoryStore {
  ClinicalHistory({required Future<IDatabaseHandle> database}) : _db = database;
  final Future<IDatabaseHandle> _db;
  static const _storeName = 'clinical_histories';

  @override
  Future<void> storeAll(List<ClinicalHistoryEntity> entities) async {
    final db = await _db;
    final records = <String, Map<String, Object?>>{
      for (final entity in entities)
        entity.id: ClinicalHistorySerializer.toMap(entity),
    };
    await db.replaceAll(_storeName, records);
  }

  @override
  Future<List<ClinicalHistoryEntity>> loadAll() async {
    final db = await _db;
    final records = await db.findAll(_storeName);
    return records.map((record) {
      return ClinicalHistorySerializer.fromMap(
        Map<String, dynamic>.from(record),
      );
    }).toList();
  }

  @override
  Future<void> deleteAll() async {
    final db = await _db;
    await db.deleteAll(_storeName);
  }
}
