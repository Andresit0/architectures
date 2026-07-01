import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

void main() {
  group('CpPathProvider', () {
    test('should implement ICpPathProvider interface', () {
      final pathProvider = CpPathProvider();
      expect(pathProvider, isA<ICpPathProvider>());
    });
  });
}
