import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result<T>', () {
    const success = Success<int>(42);
    const apiError = ApiError('Server error', statusCode: 500);
    const failure = Failure<int>(apiError);

    group('fold', () {
      test('calls onSuccess when Result is Success', () {
        final result = success.fold(
          onSuccess: (data) => 'got $data',
          onFailure: (error) => 'error: ${error.userMessage}',
        );
        expect(result, 'got 42');
      });

      test('calls onFailure when Result is Failure', () {
        final result = failure.fold(
          onSuccess: (data) => 'got $data',
          onFailure: (error) => 'error: ${error.userMessage}',
        );
        expect(result, 'error: Server error');
      });
    });
  });

  group('guard()', () {
    test('returns Success on normal execution', () async {
      final result = await guard(() async => 42);
      expect(result, isA<Success<int>>());
      expect((result as Success<int>).data, 42);
    });

    test('catches Exception and wraps in UnexpectedError', () async {
      final result = await guard<int>(() async => throw Exception('boom'));
      expect(result, isA<Failure<int>>());
      final failure = result as Failure<int>;
      expect(failure.error, isA<UnexpectedError>());
      expect(failure.error.technicalMessage, contains('boom'));
    });

    test(
      'catches Error (not just Exception) and wraps in UnexpectedError',
      () async {
        final result = await guard<int>(
          () async => throw ArgumentError('bad arg'),
        );
        expect(result, isA<Failure<int>>());
        final failure = result as Failure<int>;
        expect(failure.error, isA<UnexpectedError>());
      },
    );
  });
}
