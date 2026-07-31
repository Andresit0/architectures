import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

void main() {
  group('Result', () {
    test('Success should have isSuccess true', () {
      const result = Success<String>('data');
      expect(result.isSuccess, isTrue);
      expect(result.isSuccess, isTrue);
    });

    test('Failure should have isFailure true', () {
      final result = Failure<String>(
        const ApiError('error'),
      );
      expect(result.isSuccess, isFalse);
      expect(result.isSuccess, isFalse);
    });

    test('Success fold should call onSuccess', () {
      const result = Success<String>('data');
      final value = result.fold(
        onSuccess: (d) => 'got $d',
        onFailure: (_) => 'error',
      );
      expect(value, 'got data');
    });

    test('Failure fold should call onFailure', () {
      final result = Failure<String>(
        const NetworkError('no internet'),
      );
      final value = result.fold(
        onSuccess: (_) => 'data',
        onFailure: (e) => 'error: ${e.userMessage}',
      );
      expect(value, contains('no internet'));
    });

    test('Success getOrElse should return data', () {
      const result = Success<String>('data');
      expect(result.fold(onSuccess: (d) => d, onFailure: (_) => 'fallback'), 'data');
    });

    test('Failure getOrElse should return fallback', () {
      final result = Failure<String>(
        const ApiError('error'),
      );
      expect(result.fold(onSuccess: (d) => d, onFailure: (_) => 'fallback'), 'fallback');
    });
  });

  group('AppError', () {
    test('NetworkError should have isNetworkRelated true', () {
      const error = NetworkError('No internet connection');
      expect(error.isNetworkRelated, isTrue);
    });

    test('ServerUnreachableError should have isNetworkRelated true', () {
      const error = ServerUnreachableError('Server under maintenance');
      expect(error.isNetworkRelated, isTrue);
    });

    test('ApiError should have statusCode', () {
      const error = ApiError('Server error', statusCode: 500);
      expect(error.statusCode, 500);
      expect(error.userMessage, 'Server error');
    });

    test('ApiError should not be network related', () {
      const error = ApiError('Server error');
      expect(error.isNetworkRelated, isFalse);
    });

    test('UnexpectedError should have userMessage', () {
      const error = UnexpectedError('Unexpected error');
      expect(error.userMessage, 'Unexpected error');
    });

    test('DeviceSecurityError should have userMessage', () {
      const error = DeviceSecurityError('Device compromised');
      expect(error.userMessage, 'Device compromised');
    });

    test('ValidationError should have optional field', () {
      const error = ValidationError('Invalid field', field: 'email');
      expect(error.field, 'email');
    });
  });

  group('Exceptions', () {
    test('ApiException should have correct toString', () {
      const exception = ApiException(404);
      expect(exception.toString(), contains('404'));
      expect(exception.toString(), contains('The server returned an error'));
    });

    test('ApiException should have correct statusCode', () {
      const exception = ApiException(500);
      expect(exception.statusCode, 500);
    });

    test('NoConnectionException should have toString', () {
      const exception = NoConnectionException();
      expect(exception.toString(), isNotEmpty);
    });

    test('ServerUnreachableException should have toString', () {
      const exception = ServerUnreachableException();
      expect(exception.toString(), isNotEmpty);
    });

    test('UnexpectedResponseException should require details parameter', () {
      const exception = UnexpectedResponseException('test details');
      expect(exception.details, 'test details');
    });
  });
}


