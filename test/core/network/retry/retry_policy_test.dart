import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/core/network/retry/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    test('standard has maxRetries 0', () {
      expect(RetryPolicy.standard.maxRetries, 0);
    });
    test('standard does not retry on timeout', () {
      expect(RetryPolicy.standard.retryOnTimeout, false);
    });
    test('idempotent has maxRetries 2', () {
      expect(RetryPolicy.idempotent.maxRetries, 2);
    });
    test('idempotent retries on timeout', () {
      expect(RetryPolicy.idempotent.retryOnTimeout, true);
    });
  });
}
