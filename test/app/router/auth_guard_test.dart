import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';
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

    test(
      'redirects to login with from= when not authenticated on non-login route',
      () {
        final result = guard.redirect(
          location: AppRoute.clinicalHistory.path,
          isAuthenticated: false,
        );
        expect(
          result,
          '${AppRoute.login.path}?from='
          '${Uri.encodeComponent(AppRoute.clinicalHistory.path)}',
        );
      },
    );

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

    test('restores deep-link target from query parameter after login', () {
      final result = guard.redirect(
        location: AppRoute.login.path,
        from: AppRoute.clinicalHistory.path,
        isAuthenticated: true,
      );
      expect(result, AppRoute.clinicalHistory.path);
    });

    test(
      'does NOT restore login as deep-link target (redirect loop guard)',
      () {
        final result = guard.redirect(
          location: AppRoute.login.path,
          from: AppRoute.login.path,
          isAuthenticated: true,
        );
        expect(result, AppRoute.clinicalHistory.path);
      },
    );

    test('does NOT restore an unknown deep-link target', () {
      final result = guard.redirect(
        location: AppRoute.login.path,
        from: '/unknown',
        isAuthenticated: true,
      );
      expect(result, AppRoute.clinicalHistory.path);
    });

    test('does NOT restore an empty from value', () {
      final result = guard.redirect(
        location: AppRoute.login.path,
        from: '',
        isAuthenticated: true,
      );
      expect(result, AppRoute.clinicalHistory.path);
    });

    test(
      'returns null for an empty location (no match, let errorBuilder show)',
      () {
        final result = guard.redirect(location: '', isAuthenticated: false);
        expect(result, isNull);
      },
    );
  });
}
