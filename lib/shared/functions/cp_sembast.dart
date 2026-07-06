part of '_function.lib.dart';

final _sembastSessionStore = intMapStoreFactory.store('sessions');

abstract class ICpSembast {
  Future<void> clearSession();
}

class CpSembast implements ICpSembast {
  CpSembast({Future<Database>? database})
      : _db = database ?? AppDatabase().database;

  final Future<Database> _db;

  @override
  Future<void> clearSession() async {
    final db = await _db;
    await _sembastSessionStore.delete(db);
  }
}
