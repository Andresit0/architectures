import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:clean_architecture_sdd_harness/core/database/app_database.dart';
import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:clean_architecture_sdd_harness/core/database/secure_storage_key_service.dart';

import '../../helpers/mocks.dart';

void main() {
  late AppDatabase appDb;

  setUp(() {
    appDb = AppDatabase(
      databaseFactory: newDatabaseFactoryMemory(),
      keyService: DatabaseKeyService(storage: FakeSecureStorage()),
    );
  });

  tearDown(() async {
    await appDb.resetDatabase();
  });

  Future<IDatabaseHandle> getHandle() => appDb.database;

  group('AppDatabase.resetDatabase', () {
    test('old database handle throws after reset', () async {
      final handle = await getHandle();
      await handle.replaceAll('test', {
        'k': {'v': 'value'},
      });

      await appDb.resetDatabase();

      await expectLater(handle.findAll('test'), throwsA(isA<Exception>()));
    });

    test('new database instance is usable after reset', () async {
      final handle = await getHandle();
      await handle.replaceAll('test', {
        'k': {'v': 'value'},
      });

      await appDb.resetDatabase();

      final handle2 = await getHandle();
      await handle2.replaceAll('test', {
        'k': {'v': 'new-data'},
      });
      final records = await handle2.findAll('test');
      expect(records, hasLength(1));
      expect(records.first['v'], 'new-data');
    });

    test('clears all stored data', () async {
      final handle = await getHandle();
      await handle.replaceAll('test_store', {
        'k': {'v': 'value'},
      });
      expect(await handle.findAll('test_store'), hasLength(1));

      await appDb.resetDatabase();

      final handle2 = await getHandle();
      expect(await handle2.findAll('test_store'), isEmpty);
    });

    test('is idempotent when called on already-reset database', () async {
      await appDb.resetDatabase();
      await appDb.resetDatabase();

      final handle = await getHandle();
      await handle.replaceAll('test', {
        'k': {'v': 'value'},
      });
      expect(await handle.findAll('test'), hasLength(1));
    });
  });
}
