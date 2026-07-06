import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

void main() {
  late Database db;
  late CpSembast cpSembast;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase('memory');
    cpSembast = CpSembast(database: Future.value(db));
  });

  tearDown(() async => db.close());

  group('CpSembast', () {
    test('implements ICpSembast', () {
      expect(cpSembast, isA<ICpSembast>());
    });

    test('clearSession runs without error', () async {
      await cpSembast.clearSession();
    });
  });
}
