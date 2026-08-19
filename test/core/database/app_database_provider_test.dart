import 'package:clean_architecture_sdd_harness/core/database/app_database_provider.dart';
import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appDatabaseProvider', () {
    test('should provide an IAppDatabase', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final db = container.read(appDatabaseProvider);
      expect(db, isA<IAppDatabase>());
    });
  });
}
