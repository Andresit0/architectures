import 'package:clean_architecture_sdd_harness/core/database/sembast_db_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/database/tables/lab_results.dart';
import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_kind.dart';
import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_reference_range_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/lab_results/lab_result_value_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database db;
  late LabResults store;

  final numeric = LabResultEntity(
    id: 'lr_0001',
    testCode: 'HB',
    testName: 'Hemoglobina',
    category: 'Hematología',
    unit: 'g/dL',
    kind: LabResultKind.numeric,
    referenceRange: const LabResultReferenceRangeEntity(low: 13.0, high: 17.0),
    values: [
      LabResultValueEntity(
        date: DateTime(2026, 8, 10),
        value: 16.8,
        textValue: null,
      ),
    ],
  );
  final text = LabResultEntity(
    id: 'lr_0005',
    testCode: 'GRUPO',
    testName: 'Grupo sanguíneo',
    category: 'Inmunohematología',
    unit: null,
    kind: LabResultKind.text,
    referenceRange: null,
    values: [
      LabResultValueEntity(
        date: DateTime(2026, 8, 10),
        value: null,
        textValue: 'A Positivo (A+)',
      ),
    ],
  );

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase('memory');
    store = LabResults(database: Future.value(SembastDbWrapper(db)));
    await store.deleteAll();
  });

  tearDown(() async => db.close());

  group('storeAll', () {
    test('stores multiple entities and replaces all previous data', () async {
      await store.storeAll([numeric]);

      await store.storeAll([numeric, text]);

      final all = await store.loadAll();
      expect(all.length, 2);
    });
  });

  group('storeAll idempotence by id', () {
    test('duplicate ids do not create duplicate records', () async {
      final updatedNumeric = LabResultEntity(
        id: 'lr_0001',
        testCode: 'HB',
        testName: 'Hemoglobina',
        category: 'Hematología',
        unit: 'g/dL',
        kind: LabResultKind.numeric,
        referenceRange: null,
        values: [
          LabResultValueEntity(
            date: DateTime(2026, 9, 1),
            value: 14.2,
            textValue: null,
          ),
        ],
      );

      await store.storeAll([numeric, updatedNumeric, text]);

      final all = await store.loadAll();
      expect(all.length, 2);
      final lr1 = all.singleWhere((e) => e.id == 'lr_0001');
      expect(lr1.referenceRange, isNull);
    });
  });

  group('loadAll', () {
    test('returns empty list when no entities stored', () async {
      final all = await store.loadAll();
      expect(all, isEmpty);
    });

    test('returns all stored entities preserving kind and values', () async {
      await store.storeAll([numeric, text]);

      final all = await store.loadAll();
      expect(all.length, 2);
      expect(all.map((e) => e.id), containsAll(['lr_0001', 'lr_0005']));

      final restoredNumeric = all.singleWhere((e) => e.id == 'lr_0001');
      expect(restoredNumeric.kind, LabResultKind.numeric);
      expect(restoredNumeric.values.single.value, 16.8);

      final restoredText = all.singleWhere((e) => e.id == 'lr_0005');
      expect(restoredText.kind, LabResultKind.text);
      expect(restoredText.values.single.textValue, 'A Positivo (A+)');
    });
  });

  group('deleteAll', () {
    test('removes all stored entities', () async {
      await store.storeAll([numeric, text]);

      await store.deleteAll();

      final all = await store.loadAll();
      expect(all, isEmpty);
    });
  });
}
