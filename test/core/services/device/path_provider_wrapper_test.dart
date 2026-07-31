import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PathProviderWrapper', () {
    test('should implement IPathProviderWrapper interface', () {
      final pathProvider = PathProviderWrapper();
      expect(pathProvider, isA<IPathProviderWrapper>());
    });
  });
}
