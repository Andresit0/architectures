import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

void main() {
  group('FailurePropagation', () {
    late FailurePropagation failurePropagation;

    setUp(() {
      failurePropagation = FailurePropagation();
    });

    group('launch', () {
      test('should handle ApiFailure', () {
        const failure = ApiFailure();
        final result = failurePropagation.launch<String>(
          failure,
          onFailure: (msg) => 'handled: $msg',
        );
        expect(result, isNotEmpty);
        expect(result, contains('handled'));
      });

      test('should handle NoConnectionFailure', () {
        const failure = NoConnectionFailure();
        final result = failurePropagation.launch<String>(
          failure,
          onFailure: (msg) => 'handled: $msg',
        );
        expect(result, isNotEmpty);
      });

      test('should handle ServerUnreachableFailure', () {
        const failure = ServerUnreachableFailure();
        final result = failurePropagation.launch<String>(
          failure,
          onFailure: (msg) => 'handled: $msg',
        );
        expect(result, isNotEmpty);
      });

      test('should handle NoRequestFailure', () {
        const failure = NoRequestFailure();
        final result = failurePropagation.launch<String>(
          failure,
          onFailure: (msg) => 'handled: $msg',
        );
        expect(result, isNotEmpty);
      });

      test('should handle UnexpectedResponseFailure', () {
        const failure = UnexpectedResponseFailure();
        final result = failurePropagation.launch<String>(
          failure,
          onFailure: (msg) => 'handled: $msg',
        );
        expect(result, isNotEmpty);
      });

      test('should handle GoRouterFailure', () {
        const failure = GoRouterFailure();
        final result = failurePropagation.launch<String>(
          failure,
          onFailure: (msg) => 'handled: $msg',
        );
        expect(result, isNotEmpty);
      });

      test('should handle UnexpectedFailure', () {
        const failure = UnexpectedFailure();
        final result = failurePropagation.launch<String>(
          failure,
          onFailure: (msg) => 'handled: $msg',
        );
        expect(result, isNotEmpty);
      });

      test('should return correct type T', () {
        const failure = ApiFailure();
        final result = failurePropagation.launch<int>(
          failure,
          onFailure: (msg) => 42,
        );
        expect(result, 42);
      });

      test('should execute callback with failure message', () {
        const failure = ApiFailure();
        final result = failurePropagation.launch<String>(
          failure,
          onFailure: (msg) => msg,
        );
        expect(result, isNotEmpty);
      });
    });
  });
}
