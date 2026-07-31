import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_connectivity_checker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('internetServiceProvider', () {
    test('should provide an InternetService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final service = container.read(internetServiceProvider);
      expect(service, isA<InternetService>());
    });
  });

  group('connectivityCheckerProvider', () {
    test('should provide an IConnectivityChecker', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final checker = container.read(connectivityCheckerProvider);
      expect(checker, isA<IConnectivityChecker>());
    });
  });
}
