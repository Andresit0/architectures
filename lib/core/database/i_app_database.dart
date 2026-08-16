import 'package:sembast/sembast.dart';

abstract interface class IAppDatabase {
  Future<ISembastDb> get database;
  Future<void> resetDatabase();
}

abstract interface class ISembastDb {
  Database get db;
}
