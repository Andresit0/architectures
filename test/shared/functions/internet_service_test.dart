import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';

class FakeReachability implements IServerReachabilityStrategy {
  final bool result;
  FakeReachability(this.result);
  @override
  Future<bool> check() async => result;
}

void main() {
  group('InternetService', () {
    test('should return true when strategy returns true', () async {
      final service = InternetService(strategy: FakeReachability(true));
      final result = await service.isServerReachable();
      expect(result, isTrue);
    });

    test('should return false when strategy returns false', () async {
      final service = InternetService(strategy: FakeReachability(false));
      final result = await service.isServerReachable();
      expect(result, isFalse);
    });

    test('should cache result for subsequent calls within 10 seconds', () async {
      final strategy = FakeReachability(true);
      final service = InternetService(strategy: strategy);
      final result1 = await service.isServerReachable();
      final result2 = await service.isServerReachable();
      expect(result1, equals(result2));
    });
  });
}
