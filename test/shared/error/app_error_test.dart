import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppError semantics', () {
    test('NetworkError is network-related and transient', () {
      const error = NetworkError();
      expect(error.isNetworkRelated, isTrue);
      expect(error.isTransient, isTrue);
    });

    test('ServerUnreachableError is network-related and transient', () {
      const error = ServerUnreachableError();
      expect(error.isNetworkRelated, isTrue);
      expect(error.isTransient, isTrue);
    });

    test('TimeoutError is NOT network-related but IS transient', () {
      const error = TimeoutError();
      expect(error.isNetworkRelated, isFalse);
      expect(error.isTransient, isTrue);
    });

    test('ApiError is neither network-related nor transient', () {
      const error = ApiError();
      expect(error.isNetworkRelated, isFalse);
      expect(error.isTransient, isFalse);
    });

    test('UnexpectedError is neither network-related nor transient', () {
      const error = UnexpectedError();
      expect(error.isNetworkRelated, isFalse);
      expect(error.isTransient, isFalse);
    });

    test('DeviceSecurityError is neither network-related nor transient', () {
      const error = DeviceSecurityError();
      expect(error.isNetworkRelated, isFalse);
      expect(error.isTransient, isFalse);
    });

    test('ValidationError is neither network-related nor transient', () {
      const error = ValidationError();
      expect(error.isNetworkRelated, isFalse);
      expect(error.isTransient, isFalse);
    });

    test('ValidationError exposes field', () {
      const error = ValidationError(field: 'email');
      expect(error.field, 'email');
    });
  });

  group('AppError.toString()', () {
    test('includes runtimeType and technicalMessage', () {
      const error = NetworkError(technicalMessage: 'boom');
      final text = error.toString();
      expect(text, contains('NetworkError'));
      expect(text, contains('boom'));
    });
  });
}
