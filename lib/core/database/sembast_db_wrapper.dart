import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:sembast/sembast.dart';

class SembastDbWrapper implements ISembastDb {
  @override
  final Database db;
  SembastDbWrapper(this.db);
}
