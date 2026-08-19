import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result<T>', () {
    const success = Success<int>(42);
    const apiError = ApiError(technicalMessage: 'HTTP 500');
    const failure = Failure<int>(apiError);

    group('fold', () {
      test('calls onSuccess when Result is Success', () {
        final result = success.fold(
          onSuccess: (data) => 'got $data',
          onFailure: (error) => 'error',
        );
        expect(result, 'got 42');
      });

      test('calls onFailure when Result is Failure', () {
        final result = failure.fold(
          onSuccess: (data) => 'got $data',
          onFailure: (error) => 'error',
        );
        expect(result, 'error');
      });
    });
  });
}
