import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/app/router/app_route.dart';
import 'package:clean_architecture_sdd_harness/app/router/guards/auth_guard.dart';

void main() {
  group('GoRouter redirect logic via AuthGuard', () {
    late AuthGuard guard;

    setUp(() {
      guard = const AuthGuard();
    });

    test('redirects to clinical history when authenticated on login route', () {
      final result = guard.redirect(
        location: AppRoute.login.path,
        isAuthenticated: true,
      );
      expect(result, AppRoute.clinicalHistory.path);
    });

    test('redirects to login when not authenticated on non-login route', () {
      final result = guard.redirect(
        location: AppRoute.clinicalHistory.path,
        isAuthenticated: false,
      );
      expect(result, AppRoute.login.path);
    });

    test('returns null when authenticated on non-login route', () {
      final result = guard.redirect(
        location: AppRoute.clinicalHistory.path,
        isAuthenticated: true,
      );
      expect(result, isNull);
    });

    test('returns null when not authenticated on login route', () {
      final result = guard.redirect(
        location: AppRoute.login.path,
        isAuthenticated: false,
      );
      expect(result, isNull);
    });
  });
}
