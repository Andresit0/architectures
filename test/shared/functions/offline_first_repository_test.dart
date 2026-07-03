import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

void main() {
  group('fetchOrFallback', () {
    test('returns Right from remote when remote succeeds', () async {
      final result = await fetchOrFallback(
        remote: () async => const Right<Failure, String>('remote_data'),
        local: () async => const Right<Failure, String?>('local_data'),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (data) => expect(data, 'remote_data'),
      );
    });

    test('falls back to local when remote fails with NoConnectionFailure',
        () async {
      final result = await fetchOrFallback(
        remote: () async => const Left<Failure, String>(NoConnectionFailure()),
        local: () async => const Right<Failure, String?>('local_data'),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (data) => expect(data, 'local_data'),
      );
    });

    test('falls back to local when remote fails with ServerUnreachableFailure',
        () async {
      final result = await fetchOrFallback(
        remote: () async =>
            const Left<Failure, String>(ServerUnreachableFailure()),
        local: () async => const Right<Failure, String?>('local_data'),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (data) => expect(data, 'local_data'),
      );
    });

    test(
        'returns Left when remote fails with connection error and local is null',
        () async {
      final result = await fetchOrFallback(
        remote: () async => const Left<Failure, String>(NoConnectionFailure()),
        local: () async => const Right<Failure, String?>(null),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NoConnectionFailure>()),
        (_) => fail('should be Left'),
      );
    });

    test('does NOT fall back when remote fails with ApiFailure', () async {
      final result = await fetchOrFallback(
        remote: () async => const Left<Failure, String>(ApiFailure()),
        local: () async => const Right<Failure, String?>('local_data'),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ApiFailure>()),
        (_) => fail('should be Left'),
      );
    });

    test('does NOT fall back when remote fails with UnexpectedFailure',
        () async {
      final result = await fetchOrFallback(
        remote: () async => const Left<Failure, String>(UnexpectedFailure()),
        local: () async => const Right<Failure, String?>('local_data'),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });
}
