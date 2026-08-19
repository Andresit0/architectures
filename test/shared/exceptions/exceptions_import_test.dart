import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exceptions from shared/exceptions/', () {
    test('ApiException from new location', () {
      expect(() => throw const ApiException(500), throwsA(isA<ApiException>()));
    });

    test('DeviceSecurityException from new location', () {
      expect(
        () => throw const DeviceSecurityException(),
        throwsA(isA<DeviceSecurityException>()),
      );
    });

    test('NoConnectionException from new location', () {
      expect(
        () => throw const NoConnectionException(),
        throwsA(isA<NoConnectionException>()),
      );
    });

    test('ServerUnreachableException from new location', () {
      expect(
        () => throw const ServerUnreachableException(),
        throwsA(isA<ServerUnreachableException>()),
      );
    });

    test('AppTimeoutException from new location', () {
      expect(
        () => throw AppTimeoutException(),
        throwsA(isA<AppTimeoutException>()),
      );
    });

    test('UnexpectedResponseException from new location', () {
      expect(
        () => throw const UnexpectedResponseException('test'),
        throwsA(isA<UnexpectedResponseException>()),
      );
    });

    test('SeamNotBoundException from new location', () {
      expect(
        () => throw SeamNotBoundException('seam must be overridden'),
        throwsA(isA<SeamNotBoundException>()),
      );
    });
  });
}
