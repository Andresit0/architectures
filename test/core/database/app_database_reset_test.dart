import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:clean_architecture_sdd_harness/core/database/app_database.dart';
import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:clean_architecture_sdd_harness/core/database/secure_storage_key_service.dart';

import '../../helpers/mocks.dart';

void main() {
  late FakeSecureStorage storage;
  late IDatabaseKeyService keyService;

  setUp(() {
    storage = FakeSecureStorage();
    keyService = DatabaseKeyService(storage: storage);
  });

  AppDatabase buildDb() => AppDatabase(
    databaseFactory: newDatabaseFactoryMemory(),
    keyService: keyService,
  );

  test('resetDatabase deletes the encryption key', () async {
    final appDb = buildDb();
    await appDb.database;
    expect(await keyService.readKey(), isNotNull);

    await appDb.resetDatabase();

    expect(await keyService.readKey(), isNull);
  });

  test(
    'a new key is generated and the database is usable after reset',
    () async {
      final appDb = buildDb();
      await appDb.database;
      final firstKey = await keyService.readKey();

      await appDb.resetDatabase();

      final IDatabaseHandle db2 = await appDb.database;
      final secondKey = await keyService.readKey();
      expect(secondKey, isNotNull);
      expect(secondKey, isNot(firstKey));

      await db2.replaceAll('test', {
        'k': {'v': 'value'},
      });
      expect(await db2.findAll('test'), hasLength(1));
    },
  );
}
