import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/configs/_configs.lib.dart';

void main() {
  group('AppUries', () {
    late AppUries uries;

    setUp(() {
      uries = CustomConfigs.uries;
    });

    test('host should match vars host', () {
      expect(uries.host, CustomConfigs.vars.host);
    });

    test('port should match vars port', () {
      expect(uries.port, CustomConfigs.vars.port);
    });
  });
}