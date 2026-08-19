import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:clean_architecture_sdd_harness/core/database/secure_storage_key_service.dart';
import 'package:clean_architecture_sdd_harness/core/database/sembast_codec.dart';
import 'package:clean_architecture_sdd_harness/core/database/sembast_db_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

class AppDatabase implements IAppDatabase {
  AppDatabase({this._pathProvider, this._databaseFactory, this._keyService});

  final IPathProviderWrapper? _pathProvider;
  final DatabaseFactory? _databaseFactory;
  final IDatabaseKeyService? _keyService;

  Future<IDatabaseHandle>? _databaseFuture;
  Database? _rawDatabase;

  IDatabaseKeyService get _effectiveKeyService =>
      _keyService ?? DatabaseKeyService();

  DatabaseFactory get _factory =>
      _databaseFactory ?? (kIsWeb ? databaseFactoryWeb : databaseFactoryIo);

  @override
  Future<IDatabaseHandle> get database {
    _databaseFuture ??= _openDatabase();
    return _databaseFuture!;
  }

  Future<String> _dbName() async {
    if (kIsWeb || _databaseFactory != null) return 'app_database.db';
    final dir = await _pathProvider!.getApplicationDocumentsDirectory();
    return '${dir.path}/app_database.db';
  }

  Future<IDatabaseHandle> _openDatabase() async {
    final password = await _resolveKey();
    final codec = getEncryptSembastCodec(password: password);
    final name = await _dbName();
    try {
      final db = await _factory.openDatabase(name, codec: codec);
      _rawDatabase = db;
      return SembastDbWrapper(db);
    } on DatabaseException catch (e) {
      if (e.code != DatabaseException.errInvalidCodec) rethrow;
      return _recoverDatabase(name, codec);
    } on FormatException {
      return _recoverDatabase(name, codec);
    }
  }

  Future<IDatabaseHandle> _recoverDatabase(
    String name,
    SembastCodec codec,
  ) async {
    await _factory.deleteDatabase(name);
    final db = await _factory.openDatabase(name, codec: codec);
    _rawDatabase = db;
    return SembastDbWrapper(db);
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
    await _rawDatabase?.close();
    _rawDatabase = null;
    await _factory.deleteDatabase(await _dbName());
    await _effectiveKeyService.deleteKey();
  }
}
