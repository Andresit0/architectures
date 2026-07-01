import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/providers/go_router_notifier_provider.dart';

void main() {
  group('GoRouterListenable', () {
    test('should initialize with correct initial value', () {
      final listenable = GoRouterListenable(true);
      expect(listenable.isAuthenticated, isTrue);
    });

    test('should initialize with false initial value', () {
      final listenable = GoRouterListenable(false);
      expect(listenable.isAuthenticated, isFalse);
    });

    test('should notify listeners when value changes from false to true', () {
      final listenable = GoRouterListenable(false);
      var notified = false;
      listenable.addListener(() => notified = true);

      listenable.update(true);

      expect(notified, isTrue);
      expect(listenable.isAuthenticated, isTrue);
    });

    test('should notify listeners when value changes from true to false', () {
      final listenable = GoRouterListenable(true);
      var notified = false;
      listenable.addListener(() => notified = true);

      listenable.update(false);

      expect(notified, isTrue);
      expect(listenable.isAuthenticated, isFalse);
    });

    test('should NOT notify listeners when value remains the same', () {
      final listenable = GoRouterListenable(true);
      var notified = false;
      listenable.addListener(() => notified = true);

      listenable.update(true);

      expect(notified, isFalse);
      expect(listenable.isAuthenticated, isTrue);
    });
  });
}
