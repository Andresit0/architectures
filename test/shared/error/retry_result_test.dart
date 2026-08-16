import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetryResult', () {
    test('RetrySuccess carries the refreshed token', () {
      const result = RetrySuccess('new_token');
      expect(result.token, 'new_token');
      expect(result, isA<RetryResult>());
    });

    test('RetryNoConnection represents a transient failure without logout', () {
      const result = RetryNoConnection();
      expect(result, isA<RetryResult>());
    });

    test('RetryFailed represents a real rejection that forces logout', () {
      const result = RetryFailed();
      expect(result, isA<RetryResult>());
    });
  });
}
