import 'dart:async' show TimeoutException;

import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/online_first.dart';

void main() {
  group('fetchOrFallback', () {
    test('returns remote success with origin remote', () async {
      final r = await fetchOrFallback<String>(
        remote: () async => 'remote_data',
        local: () async => 'local_data',
      );

      expect(r.result.isSuccess, isTrue);
      expect(r.origin, DataOrigin.remote);
      r.result.fold(
        onSuccess: (data) => expect(data, 'remote_data'),
        onFailure: (_) => fail('should be success'),
      );
    });

    test(
      'falls back to local cache with origin cache on NoConnectionException',
      () async {
        final r = await fetchOrFallback<String>(
          remote: () async => throw const NoConnectionException(),
          local: () async => 'local_data',
        );

        expect(r.result.isSuccess, isTrue);
        expect(r.origin, DataOrigin.cache);
        r.result.fold(
          onSuccess: (data) => expect(data, 'local_data'),
          onFailure: (_) => fail('should be success'),
        );
      },
    );

    test(
      'falls back to local cache on ServerUnreachableException with origin cache',
      () async {
        final r = await fetchOrFallback<String>(
          remote: () async => throw const ServerUnreachableException(),
          local: () async => 'local_data',
        );

        expect(r.result.isSuccess, isTrue);
        expect(r.origin, DataOrigin.cache);
        r.result.fold(
          onSuccess: (data) => expect(data, 'local_data'),
          onFailure: (_) => fail('should be success'),
        );
      },
    );

    test(
      'does NOT fall back when remote fails with TimeoutException',
      () async {
        final r = await fetchOrFallback<String>(
          remote: () async => throw TimeoutException('slow server'),
          local: () async => 'local_data',
        );

        expect(r.result.isSuccess, isFalse);
        expect(r.origin, DataOrigin.remote);
        r.result.fold(
          onSuccess: (_) => fail('should be Failure'),
          onFailure: (error) => expect(error, isA<TimeoutError>()),
        );
      },
    );

    test(
      'returns remote failure when remote is offline and local has no data',
      () async {
        final r = await fetchOrFallback<String>(
          remote: () async => throw const NoConnectionException(),
          local: () async => null,
        );

        expect(r.result.isSuccess, isFalse);
        expect(r.origin, DataOrigin.remote);
        r.result.fold(
          onSuccess: (_) => fail('should be Failure'),
          onFailure: (error) => expect(error, isA<NetworkError>()),
        );
      },
    );

    test(
      'invokes onRemoteSuccess with remote data on remote success',
      () async {
        String? captured;
        final r = await fetchOrFallback<String>(
          remote: () async => 'remote_data',
          local: () async => 'local_data',
          onRemoteSuccess: (data) async {
            captured = data;
          },
        );

        expect(r.result.isSuccess, isTrue);
        expect(r.origin, DataOrigin.remote);
        expect(captured, 'remote_data');
      },
    );

    test(
      'returns failure with origin remote when onRemoteSuccess throws',
      () async {
        final r = await fetchOrFallback<String>(
          remote: () async => 'remote_data',
          local: () async => 'local_data',
          onRemoteSuccess: (_) async => throw Exception('db error'),
        );

        expect(r.result.isSuccess, isFalse);
        expect(r.origin, DataOrigin.remote);
        r.result.fold(
          onSuccess: (_) => fail('should be Failure'),
          onFailure: (error) => expect(error, isA<UnexpectedError>()),
        );
      },
    );

    test(
      'rethrows programming errors from onRemoteSuccess (fail-fast)',
      () async {
        expect(
          () => fetchOrFallback<String>(
            remote: () async => 'remote_data',
            local: () async => 'local_data',
            onRemoteSuccess: (_) async => throw StateError('boom'),
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test(
      'does NOT invoke onRemoteSuccess when remote fails with ApiException',
      () async {
        var invoked = false;
        final r = await fetchOrFallback<String>(
          remote: () async => throw const ApiException(401),
          local: () async => 'local_data',
          onRemoteSuccess: (_) async {
            invoked = true;
          },
        );

        expect(r.result.isSuccess, isFalse);
        expect(r.origin, DataOrigin.remote);
        expect(invoked, isFalse);
        r.result.fold(
          onSuccess: (_) => fail('should be Failure'),
          onFailure: (error) => expect(error, isA<ApiError>()),
        );
      },
    );

    test(
      'does NOT invoke onRemoteSuccess on network failure fallback',
      () async {
        var invoked = false;
        final r = await fetchOrFallback<String>(
          remote: () async => throw const NoConnectionException(),
          local: () async => 'local_data',
          onRemoteSuccess: (_) async {
            invoked = true;
          },
        );

        expect(r.result.isSuccess, isTrue);
        expect(r.origin, DataOrigin.cache);
        expect(invoked, isFalse);
        r.result.fold(
          onSuccess: (data) => expect(data, 'local_data'),
          onFailure: (_) => fail('should be success'),
        );
      },
    );

    test('does NOT fall back when remote fails with ApiException', () async {
      var localCalled = false;
      final r = await fetchOrFallback<String>(
        remote: () async => throw const ApiException(401),
        local: () async {
          localCalled = true;
          return 'local_data';
        },
      );

      expect(r.result.isSuccess, isFalse);
      expect(r.origin, DataOrigin.remote);
      expect(localCalled, isFalse);
      r.result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<ApiError>()),
      );
    });

    test(
      'does NOT fall back when remote fails with a generic Exception',
      () async {
        final r = await fetchOrFallback<String>(
          remote: () async => throw Exception('unexpected'),
          local: () async => 'local_data',
        );

        expect(r.result.isSuccess, isFalse);
        expect(r.origin, DataOrigin.remote);
        r.result.fold(
          onSuccess: (_) => fail('should be Failure'),
          onFailure: (error) => expect(error, isA<UnexpectedError>()),
        );
      },
    );

    test('rethrows raw remote programming Error (fail-fast)', () async {
      expect(
        () => fetchOrFallback<String>(
          remote: () async => throw StateError('boom'),
          local: () async => 'local_data',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('surfaces local failure with stack trace and origin cache', () async {
      final r = await fetchOrFallback<String>(
        remote: () async => throw const NoConnectionException(),
        local: () async => throw Exception('db corrupt'),
      );

      expect(r.result.isSuccess, isFalse);
      expect(r.origin, DataOrigin.cache);
      r.result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) {
          expect(error, isA<UnexpectedError>());
          expect(
            error.stackTrace,
            isNotNull,
            reason: 'la falla local debe preservar su stack trace',
          );
        },
      );
    });

    test('cache write-through failure keeps origin remote', () async {
      final r = await fetchOrFallback<String>(
        remote: () async => 'remote_data',
        local: () async => 'local_data',
        onRemoteSuccess: (_) async => throw Exception('cache write failed'),
      );

      expect(r.result.isSuccess, isFalse);
      expect(r.origin, DataOrigin.remote);
      r.result.fold(
        onSuccess: (_) => fail('should be Failure'),
        onFailure: (error) => expect(error, isA<UnexpectedError>()),
      );
    });
  });
}
