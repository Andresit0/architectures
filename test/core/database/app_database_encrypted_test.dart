import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:clean_architecture_sdd_harness/core/database/app_database.dart';
import 'package:clean_architecture_sdd_harness/core/database/secure_storage_key_service.dart';

import '../../helpers/mocks.dart';

void main() {
  late FakeSecureStorage storage;
  late IDatabaseKeyService keyService;

  setUp(() {
    storage = FakeSecureStorage();
    keyService = DatabaseKeyService(storage: storage);
  });

  group('in-memory encrypted database', () {
    test('opens, writes and reads through the AES-256-CBC codec', () async {
      final appDb = AppDatabase(
        databaseFactory: newDatabaseFactoryMemory(),
        keyService: keyService,
      );

      final isDb = await appDb.database;
      final store = intMapStoreFactory.store('t');
      await store.add(isDb.db, {'k': 'v'});

      final records = await store.find(isDb.db);
      expect(records, hasLength(1));
      expect(records.first.value['k'], 'v');
    });
  });

  group('file-based encrypted database', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('app_db_encrypted_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    AppDatabase buildIoDb() => AppDatabase(
      databaseFactory: createDatabaseFactoryIo(rootPath: tempDir.path),
      keyService: keyService,
    );

    test('persists data across instances reusing the same key', () async {
      final first = buildIoDb();
      final firstDb = await first.database;
      await intMapStoreFactory.store('t').add(firstDb.db, {'k': 'v'});

      final second = buildIoDb();
      final secondDb = await second.database;
      final records = await intMapStoreFactory.store('t').find(secondDb.db);

      expect(records, hasLength(1));
      expect(records.first.value['k'], 'v');
      expect(await keyService.readKey(), isNotNull);
    });

    test('recovers a corrupted database file by recreating it', () async {
      final first = buildIoDb();
      await (await first.database).db.close();
      final file = File('${tempDir.path}/app_database.db');
      await file.writeAsString('garbage-not-a-sembast-database');

      final recovered = buildIoDb();
      final recoveredDb = await recovered.database;
      final records = await intMapStoreFactory.store('t').find(recoveredDb.db);

      expect(records, isEmpty);
    });

    test('resetDatabase removes the file and rotates the key', () async {
      final appDb = buildIoDb();
      await appDb.database;
      final firstKey = await keyService.readKey();
      final file = File('${tempDir.path}/app_database.db');
      expect(file.existsSync(), isTrue);

      await appDb.resetDatabase();

      expect(file.existsSync(), isFalse);
      expect(await keyService.readKey(), isNull);

      final after = await appDb.database;
      final secondKey = await keyService.readKey();
      expect(secondKey, isNotNull);
      expect(secondKey, isNot(firstKey));
      expect(await intMapStoreFactory.store('t').find(after.db), isEmpty);
    });
  });
}
