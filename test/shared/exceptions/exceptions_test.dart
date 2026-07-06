import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

class TestFailure extends Failure {
  const TestFailure(super.message);
}

void main() {
  group('Failures', () {
    test('Failure should have correct message', () {
      const failure = TestFailure('test message');
      expect(failure.message, 'test message');
    });

    test('ApiFailure should have default message', () {
      const failure = ApiFailure();
      expect(failure.message, 'The server returned an error. Please try again later.');
    });

    test('NoConnectionFailure should have correct message', () {
      const failure = NoConnectionFailure();
      expect(failure.message, 'No internet connection');
    });

    test('ServerUnreachableFailure should have correct message', () {
      const failure = ServerUnreachableFailure();
      expect(failure.message, 'Server under maintenance');
    });

    test('UnexpectedFailure should have default message', () {
      const failure = UnexpectedFailure();
      expect(failure.message, 'An unexpected error occurred. Please try again later.');
    });

    test('UnexpectedResponseFailure should have correct message', () {
      const failure = UnexpectedResponseFailure();
      expect(failure.message, 'Unexpected server response. Please try again later.');
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