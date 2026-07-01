import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullname => text()();
  TextColumn get token => text()();
  DateTimeColumn get savedAt => dateTime()();
}

@DriftDatabase(tables: [Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'app_database');

  Future<Session?> readSession() =>
      (select(sessions)..limit(1)).getSingleOrNull();

  Future<void> saveSession({
    required String fullname,
    required String token,
  }) async {
    await delete(sessions).go();
    await into(sessions).insert(
      SessionsCompanion.insert(
        fullname: fullname,
        token: token,
        savedAt: DateTime.now(),
      ),
    );
  }

  Future<void> clearSession() => delete(sessions).go();
}
