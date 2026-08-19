import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:clean_architecture_sdd_harness/core/database/app_database.dart';
import 'package:clean_architecture_sdd_harness/core/database/sembast_db_wrapper.dart';
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

      final handle = await appDb.database;
      await handle.replaceAll('t', {
        'k': {'v': 'value'},
      });

      final records = await handle.findAll('t');
      expect(records, hasLength(1));
      expect(records.first['v'], 'value');
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
      final firstHandle = await first.database;
      await firstHandle.replaceAll('t', {
        'k': {'v': 'value'},
      });

      final second = buildIoDb();
      final secondHandle = await second.database;
      final records = await secondHandle.findAll('t');

      expect(records, hasLength(1));
      expect(records.first['v'], 'value');
      expect(await keyService.readKey(), isNotNull);
    });

    test('recovers a corrupted database file by recreating it', () async {
      final first = buildIoDb();
      final firstHandle = await first.database as SembastDbWrapper;
      await firstHandle.db.close();
      final file = File('${tempDir.path}/app_database.db');
      await file.writeAsString('garbage-not-a-sembast-database');

      final recovered = buildIoDb();
      final recoveredHandle = await recovered.database;
      final records = await recoveredHandle.findAll('t');

      expect(records, isEmpty);
    });

    test('resetDatabase removes the file and rotates the key', () async {
      final appDb = buildIoDb();
      final handle = await appDb.database;
      await handle.replaceAll('t', {
        'k': {'v': 'value'},
      });
      final firstKey = await keyService.readKey();
      final file = File('${tempDir.path}/app_database.db');
      expect(file.existsSync(), isTrue);

      await appDb.resetDatabase();

      expect(file.existsSync(), isFalse);
      expect(await keyService.readKey(), isNull);

      final afterHandle = await appDb.database;
      final secondKey = await keyService.readKey();
      expect(secondKey, isNotNull);
      expect(secondKey, isNot(firstKey));
      expect(await afterHandle.findAll('t'), isEmpty);
    });
  });
}
