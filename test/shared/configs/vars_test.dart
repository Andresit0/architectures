import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/configs/_configs.lib.dart';

void main() {
  group('Vars', () {
    test('appName should be tudesarrollador', () {
      final vars = CustomConfigs.vars;
      expect(vars.appName, 'tudesarrollador');
    });

    test('host should have default value', () {
      final vars = CustomConfigs.vars;
      expect(vars.host, isNotEmpty);
    });

    test('port should have default value', () {
      final vars = CustomConfigs.vars;
      expect(vars.port, greaterThan(0));
    });

    test('useMockRepository should default to false', () {
      final vars = CustomConfigs.vars;
      expect(vars.useMockRepository, isFalse);
    });

    test('isReleaseMode should default to false', () {
      final vars = CustomConfigs.vars;
      expect(vars.isReleaseMode, isFalse);
    });
  });
}