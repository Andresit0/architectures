import 'package:clean_architecture_sdd_harness/core/database/serializers/lab_results_serializer.dart';
import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_entity.dart';

class LabResults implements ILabResultsStore {
  LabResults({required Future<IDatabaseHandle> database}) : _db = database;
  final Future<IDatabaseHandle> _db;
  static const _storeName = 'lab_results';

  @override
  Future<void> storeAll(List<LabResultEntity> entities) async {
    final db = await _db;
    final records = <String, Map<String, Object?>>{
      for (final entity in entities)
        entity.id: LabResultsSerializer.toMap(entity),
    };
    await db.replaceAll(_storeName, records);
  }

  @override
  Future<List<LabResultEntity>> loadAll() async {
    final db = await _db;
    final records = await db.findAll(_storeName);
    return records.map((record) {
      return LabResultsSerializer.fromMap(Map<String, dynamic>.from(record));
    }).toList();
  }

  @override
  Future<void> deleteAll() async {
    final db = await _db;
    await db.deleteAll(_storeName);
  }
}
