import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/providers/go_router_notifier_provider.dart';

// The redirect logic extracted for testing:
// - If not authenticated and not on login route → redirect to '/'
// - If authenticated and on login route → redirect to clinical history route
// - Otherwise → null (no redirect)
String? redirectLogic(GoRouterListenable listenable, String location) {
  final authenticated = listenable.isAuthenticated;
  final isLoginRoute = location == '/';
  if (!authenticated && !isLoginRoute) return '/';
  if (authenticated && isLoginRoute) return '/${CpGoRouter.nameClinicalHistory}';
  return null;
}

void main() {
  group('GoRouter redirect logic', () {
    late GoRouterListenable authenticated;
    late GoRouterListenable notAuthenticated;

    setUp(() {
      authenticated = GoRouterListenable(true);
      notAuthenticated = GoRouterListenable(false);
    });

    test('redirects to clinical history when authenticated on login route', () {
      final result = redirectLogic(authenticated, '/');
      expect(result, '/${CpGoRouter.nameClinicalHistory}');
    });

    test('redirects to login when not authenticated on non-login route', () {
      final result = redirectLogic(notAuthenticated, '/${CpGoRouter.nameClinicalHistory}');
      expect(result, '/');
    });

    test('returns null when authenticated on non-login route', () {
      final result = redirectLogic(authenticated, '/${CpGoRouter.nameClinicalHistory}');
      expect(result, isNull);
    });

    test('returns null when not authenticated on login route', () {
      final result = redirectLogic(notAuthenticated, '/');
      expect(result, isNull);
    });
  });
}
