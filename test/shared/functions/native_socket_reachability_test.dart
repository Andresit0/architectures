import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

void main() {
  group('NativeSocketReachability', () {
    test('should implement ServerReachabilityStrategy', () {
      final reachability = NativeSocketReachability(
        host: 'localhost',
        port: 8080,
      );
      expect(reachability, isA<IServerReachabilityStrategy>());
    });

    test('should construct with custom timeout', () {
      final reachability = NativeSocketReachability(
        host: 'localhost',
        port: 8080,
        timeout: const Duration(seconds: 10),
      );
      expect(reachability, isA<NativeSocketReachability>());
    });

    test('check returns false for unreachable host', () async {
      final reachability = NativeSocketReachability(
        host: '192.0.2.1', // TEST-NET address, guaranteed unreachable
        port: 1,
        timeout: const Duration(seconds: 1),
      );
      final result = await reachability.check();
      expect(result, isFalse);
    });

    test('check returns false for refused connection', () async {
      // Port 0 is invalid, should cause connection error
      final reachability = NativeSocketReachability(
        host: 'localhost',
        port: 0,
        timeout: const Duration(seconds: 1),
      );
      final result = await reachability.check();
      expect(result, isFalse);
    });
  });
}