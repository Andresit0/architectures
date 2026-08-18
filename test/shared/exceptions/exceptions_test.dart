import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

void main() {
  group('Exceptions', () {
    test('ApiException toString is technical and localized at UI', () {
      const exception = ApiException(404);
      expect(exception.toString(), contains('HTTP 404'));
      expect(exception.toString(), isNot(contains('Please try again later')));
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

    test('DeviceSecurityException should have toString with message', () {
      const exception = DeviceSecurityException();
      expect(exception.toString(), contains('jailbroken or rooted'));
      expect(const DeviceSecurityException('custom').message, 'custom');
    });

    test('UnexpectedResponseException should require details parameter', () {
      const exception = UnexpectedResponseException('test details');
      expect(exception.details, 'test details');
    });

    test('AppTimeoutException is const-constructible with default message', () {
      const exception = AppTimeoutException();
      expect(exception.message, 'The request timed out');
    });

    test('AppTimeoutException should have toString', () {
      const exception = AppTimeoutException(message: 'timeout in /login');
      expect(exception.toString(), contains('timeout in /login'));
    });

    test('SeamNotBoundException is an Error (NOT an Exception) so guard() '
        'keeps fail-fast and never swallows it as Failure', () {
      final exception = SeamNotBoundException('provider must be overridden');
      expect(exception, isA<Error>());
      expect(exception, isNot(isA<Exception>()));
    });

    test('SeamNotBoundException exposes the message and toString', () {
      final exception = SeamNotBoundException(
        'appNavigatorProvider must be overridden',
      );
      expect(exception.message, 'appNavigatorProvider must be overridden');
      expect(exception.toString(), 'appNavigatorProvider must be overridden');
    });
  });
}
