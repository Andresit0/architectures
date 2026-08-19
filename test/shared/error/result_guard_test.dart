import 'dart:async';

import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('guard', () {
    test('should return Success when function succeeds', () async {
      final result = await guard(() async => 'success');

      expect(result, isA<Success<String>>());
    });

    test('should return Failure with ApiError preserving the HTTP code '
        'in technicalMessage', () async {
      final result = await guard<int>(() async {
        throw const ApiException(500);
      });

      expect(result, isA<Failure<int>>());
      final error = (result as Failure<int>).error;
      expect(error, isA<ApiError>());
      expect(error.technicalMessage, 'HTTP 500');
    });

    test(
      'should return Failure with NetworkError on NoConnectionException',
      () async {
        final result = await guard<int>(() async {
          throw const NoConnectionException();
        });

        expect(result, isA<Failure<int>>());
        expect((result as Failure<int>).error, isA<NetworkError>());
      },
    );

    test(
      'should return Failure with ServerUnreachableError on ServerUnreachableException',
      () async {
        final result = await guard<int>(() async {
          throw const ServerUnreachableException();
        });

        expect(result, isA<Failure<int>>());
        expect((result as Failure<int>).error, isA<ServerUnreachableError>());
      },
    );

    test(
      'should return Failure with UnexpectedError on UnexpectedResponseException',
      () async {
        final result = await guard<int>(() async {
          throw const UnexpectedResponseException('details');
        });

        expect(result, isA<Failure<int>>());
        final error = (result as Failure<int>).error as UnexpectedError;
        expect(error, isA<UnexpectedError>());
        expect(error.technicalMessage, 'details');
      },
    );

    test(
      'should return Failure with DeviceSecurityError on DeviceSecurityException',
      () async {
        final result = await guard<int>(() async {
          throw const DeviceSecurityException();
        });

        expect(result, isA<Failure<int>>());
        expect((result as Failure<int>).error, isA<DeviceSecurityError>());
      },
    );

    test('should return Failure with TimeoutError preserving the message '
        'on AppTimeoutException', () async {
      final result = await guard<int>(() async {
        throw AppTimeoutException(message: 'timeout in /login');
      });

      expect(result, isA<Failure<int>>());
      final error = (result as Failure<int>).error;
      expect(error, isA<TimeoutError>());
      expect(error.technicalMessage, 'timeout in /login');
    });

    test('should return Failure with TimeoutError preserving the message '
        'on raw TimeoutException', () async {
      final result = await guard<int>(() async {
        throw TimeoutException('timed out');
      });
      expect(result, isA<Failure<int>>());
      final error = (result as Failure<int>).error;
      expect(error, isA<TimeoutError>());
      expect(error.technicalMessage, 'timed out');
    });

    test(
      'should return Failure with UnexpectedError on generic exception',
      () async {
        final result = await guard<int>(() async {
          throw Exception('generic error');
        });

        expect(result, isA<Failure<int>>());
        expect((result as Failure<int>).error, isA<UnexpectedError>());
      },
    );

    test('guard returns ApiError without localizer', () async {
      final result = await guard<int>(
        () async => throw const ApiException(400),
      );

      expect(result, isA<Failure<int>>());
      expect((result as Failure<int>).error, isA<ApiError>());
    });

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

    test('rethrows Error (programming errors) instead of wrapping', () async {
      expect(
        () => guard<int>(() async => throw ArgumentError('bad arg')),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
