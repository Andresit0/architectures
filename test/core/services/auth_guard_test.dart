import 'package:clean_architecture_sdd_harness/app/router/app_route.dart';
import 'package:clean_architecture_sdd_harness/app/router/guards/auth_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthGuard', () {
    late AuthGuard guard;

    setUp(() {
      guard = const AuthGuard();
    });

    test('returns null when authenticated and on a non-login route', () {
      final result = guard.redirect(
        location: AppRoute.clinicalHistory.path,
        isAuthenticated: true,
      );
      expect(result, isNull);
    });

    test('redirects to / when not authenticated and on a protected route', () {
      final result = guard.redirect(
        location: AppRoute.clinicalHistory.path,
        isAuthenticated: false,
      );
      expect(result, AppRoute.login.path);
    });

    test('redirects to clinical history when authenticated and on login route', () {
      final result = guard.redirect(
        location: AppRoute.login.path,
        isAuthenticated: true,
      );
      expect(result, AppRoute.clinicalHistory.path);
    });

    test('returns null when not authenticated and on login route', () {
      final result = guard.redirect(
        location: AppRoute.login.path,
        isAuthenticated: false,
      );
      expect(result, isNull);
    });
  });
}
