import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:clean_architecture_sdd_harness/core/database/sembast_codec.dart';

void main() {
  test('getEncryptSembastCodec exposes the encrypt signature', () {
    final codec = getEncryptSembastCodec(password: 'test-password');

    expect(codec.signature, 'encrypt');
  });

  test(
    'round-trips values through a real sembast database with the codec',
    () async {
      final codec = getEncryptSembastCodec(password: 'test-password');
      final db = await newDatabaseFactoryMemory().openDatabase(
        'codec_mem',
        codec: codec,
      );
      addTearDown(db.close);

      final store = intMapStoreFactory.store('t');
      await store.add(db, {'a': 1, 'b': 'x'});

      final records = await store.find(db);
      expect(records, hasLength(1));
      expect(records.first.value['a'], 1);
      expect(records.first.value['b'], 'x');
    },
  );
}
