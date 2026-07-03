import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/database/_database.lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database db;
  late PatientInfo store;
  const patient = PatientEntity(id: 'PT-98765', name: 'John Doe');

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase('memory');
    store = PatientInfo(database: Future.value(db));
    await store.delete();
  });

  tearDown(() async => db.close());

  group('PatientInfo — unit tests', () {
    test('implements IPatientInfoStore', () {
      expect(store, isA<IPatientInfoStore>());
    });

    test('load returns null when empty', () async {
      final result = await store.load();
      expect(result, isNull);
    });

    test('save + load roundtrip returns stored patient', () async {
      await store.save(patient);

      final result = await store.load();
      expect(result, isNotNull);
      expect(result!.id, 'PT-98765');
      expect(result.name, 'John Doe');
    });

    test('delete removes patient data', () async {
      await store.save(patient);
      expect(await store.load(), isNotNull);

      await store.delete();
      expect(await store.load(), isNull);
    });

    test('save replaces previous patient data', () async {
      await store.save(patient);
      const updated = PatientEntity(id: 'PT-12345', name: 'Jane Smith');

      await store.save(updated);

      final result = await store.load();
      expect(result, isNotNull);
      expect(result!.id, 'PT-12345');
      expect(result.name, 'Jane Smith');
    });
  });
}
