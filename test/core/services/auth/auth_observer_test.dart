import 'package:clean_architecture_sdd_harness/core/services/auth/auth_observer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthObserver', () {
    test('initial state is false', () {
      final observer = AuthObserver();
      expect(observer.isAuthenticated, isFalse);
    });

    test('update(true) sets authenticated and notifies', () {
      final observer = AuthObserver();
      bool notified = false;
      observer.addListener(() => notified = true);
      observer.update(true);
      expect(observer.isAuthenticated, isTrue);
      expect(notified, isTrue);
    });

    test('update(false) sets not authenticated and notifies', () {
      final observer = AuthObserver();
      observer.update(true); // first set true
      bool notified = false;
      observer.addListener(() => notified = true);
      observer.update(false);
      expect(observer.isAuthenticated, isFalse);
      expect(notified, isTrue);
    });

    test('update with same value does NOT notify (optimization)', () {
      final observer = AuthObserver();
      int notifyCount = 0;
      observer.addListener(() => notifyCount++);
      observer.update(false); // already false from initial state
      expect(
        notifyCount,
        0,
        reason: 'update with same value should NOT call notifyListeners',
      );
    });
  });
}
