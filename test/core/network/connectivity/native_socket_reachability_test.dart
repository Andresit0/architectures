import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativeSocketReachability', () {
    test('should implement ServerReachabilityStrategy', () {
      const reachability = NativeSocketReachability(
        host: 'localhost',
        port: 8080,
      );
      expect(reachability, isA<IServerReachabilityStrategy>());
    });

    test('should construct with custom timeout', () {
      const reachability = NativeSocketReachability(
        host: 'localhost',
        port: 8080,
        timeout: Duration(seconds: 10),
      );
      expect(reachability, isA<NativeSocketReachability>());
    });

    test('check returns false for unreachable host', () async {
      const reachability = NativeSocketReachability(
        host: '192.0.2.1', // TEST-NET address, guaranteed unreachable
        port: 1,
        timeout: Duration(seconds: 1),
      );
      final result = await reachability.check();
      expect(result, isFalse);
    });

    test('check returns false for refused connection', () async {
      // Port 0 is invalid, should cause connection error
      const reachability = NativeSocketReachability(
        host: 'localhost',
        port: 0,
        timeout: Duration(seconds: 1),
      );
      final result = await reachability.check();
      expect(result, isFalse);
    });
  });
}
