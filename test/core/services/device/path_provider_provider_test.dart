import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pathProviderProvider', () {
    test('should provide an IPathProviderWrapper', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = container.read(pathProviderProvider);
      expect(provider, isA<IPathProviderWrapper>());
    });
  });
}
