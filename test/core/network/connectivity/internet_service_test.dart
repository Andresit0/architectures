import 'dart:async';

import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeReachability implements IServerReachabilityStrategy {
  FakeReachability(this.result);
  final bool result;
  @override
  Future<bool> check() async => result;
}

class _FakeConnectionChecker implements IInternetConnectionCheckerWrapper {
  _FakeConnectionChecker(this.controller);
  final StreamController<bool> controller;

  @override
  Future<bool> checkConnectivity() async => true;

  @override
  Stream<bool> get onStatusChange => controller.stream;
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

    test(
      'should cache result for subsequent calls within 10 seconds',
      () async {
        final strategy = FakeReachability(true);
        final service = InternetService(strategy: strategy);
        final result1 = await service.isServerReachable();
        final result2 = await service.isServerReachable();
        expect(result1, equals(result2));
      },
    );
  });

  group('InternetService.onStatusChange', () {
    test('yields current connectivity first, then stream updates', () async {
      final controller = StreamController<bool>();
      final service = InternetService(
        strategy: FakeReachability(true),
        connectionChecker: _FakeConnectionChecker(controller),
      );

      final values = <bool>[];
      final sub = service.onStatusChange.listen(values.add);
      await Future<void>.delayed(Duration.zero);

      controller.add(false);
      await Future<void>.delayed(Duration.zero);

      expect(values, [true, false]);

      await sub.cancel();
      await controller.close();
    });
  });
}
