import 'package:clean_architecture_sdd_harness/core/network/timeouts/connection_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectionProfile standard', () {
    test('has correct connectTimeout of 10 seconds', () {
      expect(
        ConnectionProfile.standard.connectTimeout,
        const Duration(seconds: 10),
      );
    });

    test('has correct receiveTimeout of 15 seconds', () {
      expect(
        ConnectionProfile.standard.receiveTimeout,
        const Duration(seconds: 15),
      );
    });

    test('has default sendTimeout of 10 seconds', () {
      expect(
        ConnectionProfile.standard.sendTimeout,
        const Duration(seconds: 10),
      );
    });
  });

  group('ConnectionProfile constants', () {
    test('standard is a const instance', () {
      expect(ConnectionProfile.standard, isA<ConnectionProfile>());
    });
  });
}
