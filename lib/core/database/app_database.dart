import 'package:clean_architecture_sdd_harness/core/database/database_encrypt.dart';
import 'package:clean_architecture_sdd_harness/core/database/secure_storage_key_service.dart';
import 'package:clean_architecture_sdd_harness/core/database/sembast_db_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_app_database.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

class AppDatabase implements IAppDatabase {
  AppDatabase({
    this._pathProvider,
    this._databaseFactory,
    this._keyService,
  });

  final IPathProviderWrapper? _pathProvider;
  final DatabaseFactory? _databaseFactory;
  final IDatabaseKeyService? _keyService;

  Future<ISembastDb>? _databaseFuture;
  Database? _rawDatabase;

  IDatabaseKeyService get _effectiveKeyService =>
      _keyService ?? DatabaseKeyService();

  DatabaseFactory get _factory =>
      _databaseFactory ?? (kIsWeb ? databaseFactoryWeb : databaseFactoryIo);

  @override
  Future<ISembastDb> get database {
    _databaseFuture ??= _openDatabase();
    return _databaseFuture!;
  }

  Future<ISembastDb> _openDatabase() async {
    final factory = _factory;
    if (_databaseFactory != null) {
      final db = await factory.openDatabase('app_database.db');
      _rawDatabase = db;
      return SembastDbWrapper(db);
    }
    final password = await _resolveKey();
    final codec = getEncryptSembastCodec(password: password);
    if (kIsWeb) {
      final db = await factory.openDatabase('app_database.db', codec: codec);
      _rawDatabase = db;
      return SembastDbWrapper(db);
    }
    final dir = await _pathProvider!.getApplicationDocumentsDirectory();
    try {
      final db = await factory.openDatabase(
        '${dir.path}/app_database.db',
        codec: codec,
      );
      _rawDatabase = db;
      return SembastDbWrapper(db);
    } catch (_) {
      await factory.deleteDatabase('${dir.path}/app_database.db');
      final db = await factory.openDatabase(
        '${dir.path}/app_database.db',
        codec: codec,
      );
      _rawDatabase = db;
      return SembastDbWrapper(db);
    }
  }

  Future<String> _resolveKey() async {
    final existingKey = await _effectiveKeyService.readKey();
    if (existingKey != null) return existingKey;
    final newKey = _effectiveKeyService.generateKey();
    await _effectiveKeyService.saveKey(newKey);
    return newKey;
  }

  @override
  Future<void> resetDatabase() async {
    _databaseFuture = null;
    _rawDatabase?.close();
    _rawDatabase = null;
    final factory = _factory;
    if (_databaseFactory != null || kIsWeb) {
      await factory.deleteDatabase('app_database.db');
    } else {
      final dir = await _pathProvider!.getApplicationDocumentsDirectory();
      await factory.deleteDatabase('${dir.path}/app_database.db');
    }
  }
}
