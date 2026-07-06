part of '_database.lib.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;
  static final IDatabaseKeyService _keyService = DatabaseKeyService();
  static DatabaseFactory? testFactory;
  static DatabaseFactory get _factory =>
      testFactory ?? (kIsWeb ? databaseFactoryWeb : databaseFactoryIo);
  static Future<String> _resolveKey() async {
    final existingKey = await _keyService.readKey();
    if (existingKey != null) return existingKey;
    final newKey = _keyService.generateKey();
    await _keyService.saveKey(newKey);
    return newKey;
  }

  factory AppDatabase() => _instance;

  AppDatabase._internal();

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final factory = _factory;
    if (testFactory != null) {
      return await factory.openDatabase('test_db');
    }
    final password = await _resolveKey();
    final codec = getEncryptSembastCodec(password: password);
    if (kIsWeb) {
      return await factory.openDatabase(
        'app_database.db',
        codec: codec,
      );
    }
    final dir = await getApplicationDocumentsDirectory();
    try {
      return await factory.openDatabase(
        '${dir.path}/app_database.db',
        codec: codec,
      );
    } catch (_) {
      await factory.deleteDatabase('${dir.path}/app_database.db');
      return await factory.openDatabase(
        '${dir.path}/app_database.db',
        codec: codec,
      );
    }
  }

  Future<void> resetDatabase() async {
    final db = _database;
    _database = null;
    try {
      await db?.close();
    } catch (_) {
      // Database was already closed or never opened
    }
    final factory = _factory;
    if (testFactory != null) {
      await factory.deleteDatabase('test_db');
    } else if (kIsWeb) {
      await factory.deleteDatabase('app_database.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      await factory.deleteDatabase('${dir.path}/app_database.db');
    }
  }
}
