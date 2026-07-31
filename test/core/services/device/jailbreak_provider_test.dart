import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('flutterJailbreakDetectionProvider', () {
    test('should provide an IJailbreakDetectionWrapper', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final detection = container.read(flutterJailbreakDetectionProvider);
      expect(detection, isA<IJailbreakDetectionWrapper>());
    });
  });
}
