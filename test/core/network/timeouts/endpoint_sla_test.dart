import 'package:clean_architecture_sdd_harness/core/network/retry/retry_policy.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/endpoint_sla.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EndpointSla', () {
    test('has urgent with 5 second timeout', () {
      expect(EndpointSla.urgent.timeout, const Duration(seconds: 5));
    });

    test('has standard with 15 second timeout', () {
      expect(EndpointSla.standard.timeout, const Duration(seconds: 15));
    });

    test('has login with 30 second timeout', () {
      expect(EndpointSla.login.timeout, const Duration(seconds: 30));
    });

    test('has upload with 120 second timeout', () {
      expect(EndpointSla.upload.timeout, const Duration(seconds: 120));
    });

    test('has unknown with 10 second timeout', () {
      expect(EndpointSla.unknown.timeout, const Duration(seconds: 10));
    });

    test('has all expected values', () {
      expect(EndpointSla.values, hasLength(5));
    });

    test('unknown is the fallback', () {
      const values = EndpointSla.values;
      expect(
        values,
        containsAll([
          EndpointSla.urgent,
          EndpointSla.standard,
          EndpointSla.login,
          EndpointSla.upload,
          EndpointSla.unknown,
        ]),
      );
    });

    test('uses const constructor', () {
      const sla = EndpointSla.urgent;
      expect(sla, equals(sla));
    });
  });

  group('EndpointSla.retry', () {
    test('urgent uses RetryPolicy.standard', () {
      expect(EndpointSla.urgent.retry, RetryPolicy.standard);
    });

    test('standard uses RetryPolicy.standard', () {
      expect(EndpointSla.standard.retry, RetryPolicy.standard);
    });

    test('login uses RetryPolicy.idempotent', () {
      expect(EndpointSla.login.retry, RetryPolicy.idempotent);
    });

    test('upload uses RetryPolicy.idempotent', () {
      expect(EndpointSla.upload.retry, RetryPolicy.idempotent);
    });

    test('unknown uses RetryPolicy.standard', () {
      expect(EndpointSla.unknown.retry, RetryPolicy.standard);
    });

    test('urgent.retry.maxRetries is 0', () {
      expect(EndpointSla.urgent.retry.maxRetries, 0);
    });

    test('urgent.retry.retryOnTimeout is false', () {
      expect(EndpointSla.urgent.retry.retryOnTimeout, false);
    });

    test('login.retry.maxRetries is 2', () {
      expect(EndpointSla.login.retry.maxRetries, 2);
    });

    test('login.retry.retryOnTimeout is true', () {
      expect(EndpointSla.login.retry.retryOnTimeout, true);
    });
  });
}
