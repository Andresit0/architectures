import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:clean_architecture_sdd_harness/shared/database/_database.lib.dart';

void main() {
  setUp(() {
    AppDatabase.testFactory = databaseFactoryMemory;
  });

  tearDown(() async {
    await AppDatabase().resetDatabase();
    AppDatabase.testFactory = null;
  });

  group('AppDatabase.resetDatabase', () {
    test('old database handle throws after reset', () async {
      final store = intMapStoreFactory.store('test');
      final db = await AppDatabase().database;
      await store.add(db, {'key': 'value'});

      await AppDatabase().resetDatabase();

      expect(() async => await store.find(db), throwsA(isA<Exception>()));
    });

    test('new database instance is usable after reset', () async {
      final store = intMapStoreFactory.store('test');
      final db = await AppDatabase().database;
      await store.add(db, {'key': 'value'});

      await AppDatabase().resetDatabase();

      final db2 = await AppDatabase().database;
      await store.add(db2, {'key': 'new-data'});
      final records = await store.find(db2);
      expect(records, hasLength(1));
      expect(records.first.value['key'], 'new-data');
    });

    test('clears all stored data', () async {
      final store = intMapStoreFactory.store('test_store');

      final db = await AppDatabase().database;
      await store.add(db, {'key': 'value'});
      expect(await store.find(db), hasLength(1));

      await AppDatabase().resetDatabase();

      final db2 = await AppDatabase().database;
      expect(await store.find(db2), isEmpty);
    });

    test('is idempotent when called on already-reset database', () async {
      await AppDatabase().resetDatabase();
      await AppDatabase().resetDatabase();

      final db = await AppDatabase().database;
      final store = intMapStoreFactory.store('test');
      await store.add(db, {'key': 'value'});
      expect(await store.find(db), hasLength(1));
    });
  });
}
