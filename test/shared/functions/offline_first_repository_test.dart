import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/offline_first_repository.dart';

void main() {
  group('fetchOrFallback', () {
    test('returns success from remote when remote succeeds', () async {
      final result = await fetchOrFallback(
        remote: () async => Success<String>('remote_data'),
        local: () async => Success<String?>('local_data'),
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, 'remote_data'),
        onFailure: (_) => fail('should be success'),
      );
    });

    test('falls back to local when remote fails with NetworkError', () async {
      final result = await fetchOrFallback(
        remote: () async =>
            Failure<String>(const NetworkError('No internet connection')),
        local: () async => Success<String?>('local_data'),
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data, 'local_data'),
        onFailure: (_) => fail('should be success'),
      );
    });

    test(
      'falls back to local when remote fails with ServerUnreachableError',
      () async {
        final result = await fetchOrFallback(
          remote: () async => Failure<String>(
            const ServerUnreachableError('Server under maintenance'),
          ),
          local: () async => Success<String?>('local_data'),
        );

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data, 'local_data'),
          onFailure: (_) => fail('should be success'),
        );
      },
    );

    test(
      'returns failure when remote fails with connection error and local is null',
      () async {
        final result = await fetchOrFallback(
          remote: () async =>
              Failure<String>(const NetworkError('No internet connection')),
          local: () async => const Success<String?>(null),
        );

        expect(result.isSuccess, isFalse);
      },
    );

    test('does NOT fall back when remote fails with ApiError', () async {
      final result = await fetchOrFallback(
        remote: () async => Failure<String>(const ApiError('Server error')),
        local: () async => Success<String?>('local_data'),
      );

      expect(result.isSuccess, isFalse);
    });

    test('does NOT fall back when remote fails with UnexpectedError', () async {
      final result = await fetchOrFallback(
        remote: () async =>
            Failure<String>(const UnexpectedError('Unexpected error')),
        local: () async => Success<String?>('local_data'),
      );

      expect(result.isSuccess, isFalse);
    });
  });
}
