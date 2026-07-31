import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:clean_architecture_sdd_harness/core/database/app_database.dart';

void main() {
  late AppDatabase appDb;

  setUp(() {
    appDb = AppDatabase(databaseFactory: databaseFactoryMemory);
  });

  tearDown(() async {
    await appDb.resetDatabase();
  });

  Future<Database> getDb() async {
    final isDb = await appDb.database;
    return isDb.db;
  }

  group('AppDatabase.resetDatabase', () {
    test('old database handle throws after reset', () async {
      final store = intMapStoreFactory.store('test');
      final db = await getDb();
      await store.add(db, {'key': 'value'});

      await appDb.resetDatabase();

      expect(() async => await store.find(db), throwsA(isA<Exception>()));
    });

    test('new database instance is usable after reset', () async {
      final store = intMapStoreFactory.store('test');
      final db = await getDb();
      await store.add(db, {'key': 'value'});

      await appDb.resetDatabase();

      final db2 = await getDb();
      await store.add(db2, {'key': 'new-data'});
      final records = await store.find(db2);
      expect(records, hasLength(1));
      expect(records.first.value['key'], 'new-data');
    });

    test('clears all stored data', () async {
      final store = intMapStoreFactory.store('test_store');

      final db = await getDb();
      await store.add(db, {'key': 'value'});
      expect(await store.find(db), hasLength(1));

      await appDb.resetDatabase();

      final db2 = await getDb();
      expect(await store.find(db2), isEmpty);
    });

    test('is idempotent when called on already-reset database', () async {
      await appDb.resetDatabase();
      await appDb.resetDatabase();

      final db = await getDb();
      final store = intMapStoreFactory.store('test');
      await store.add(db, {'key': 'value'});
      expect(await store.find(db), hasLength(1));
    });
  });
}
