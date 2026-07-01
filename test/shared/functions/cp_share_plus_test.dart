import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';
import 'package:mocktail/mocktail.dart';

class MockCpPathProvider extends Mock implements ICpPathProvider {}

void main() {
  group('CpSharePlus', () {
    test('should implement ICpSharePlus interface', () {
      final sharePlus = CpSharePlus();
      expect(sharePlus, isA<ICpSharePlus>());
    });
  });
}
