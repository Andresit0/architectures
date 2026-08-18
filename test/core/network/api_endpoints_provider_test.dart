import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/core/config/environment_provider.dart';
import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';

void main() {
  group('appUriesProvider', () {
    test('provides an IEndpointConfig bound to the current environment', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final config = container.read(appUriesProvider);

      expect(config, isA<IEndpointConfig>());
      expect(config.login.host, 'localhost');
      expect(config.login.scheme, 'http');
      expect(config.labResults.path, '/user/clinical-history/lab-results');
    });

    test('honors environmentProvider overrides', () {
      final container = ProviderContainer(
        overrides: [
          environmentProvider.overrideWithValue(const StagingEnvironment()),
        ],
      );
      addTearDown(container.dispose);

      final config = container.read(appUriesProvider);

      expect(config.login.host, 'staging.example.com');
      expect(config.login.scheme, 'https');
      expect(config.refreshToken.host, 'staging.example.com');
      expect(config.clinicalHistory.host, 'staging.example.com');
      expect(config.labResults.path, '/user/clinical-history/lab-results');
    });

    test('uses https scheme when port is 443', () {
      const config = AppUris(env: StagingEnvironment());

      expect(config.login.scheme, 'https');
      expect(config.login.port, 443);
    });
  });
}
