import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';

void main() {
  group('AppRoute registry', () {
    test('login has path / and name login', () {
      expect(AppRoute.login.path, '/');
      expect(AppRoute.login.name, 'login');
    });

    test(
      'clinicalHistory has path /clinical-history and name clinical-history',
      () {
        expect(AppRoute.clinicalHistory.path, '/clinical-history');
        expect(AppRoute.clinicalHistory.name, 'clinical-history');
      },
    );

    test('paths are unique across the registry', () {
      final paths = AppRoute.values.map((r) => r.path).toSet();
      expect(paths.length, AppRoute.values.length);
    });

    test('names are unique across the registry', () {
      final names = AppRoute.values.map((r) => r.name).toSet();
      expect(names.length, AppRoute.values.length);
    });

    test('every path/name is non-empty', () {
      for (final route in AppRoute.values) {
        expect(route.path, isNotEmpty);
        expect(route.name, isNotEmpty);
      }
    });

    test('fromPath round-trips every registered route', () {
      for (final route in AppRoute.values) {
        expect(AppRoute.fromPath(route.path), route);
      }
    });

    test('fromPath returns correct route for login path', () {
      final result = AppRoute.fromPath(AppRoute.login.path);
      expect(result, AppRoute.login);
    });

    test('fromPath returns correct route for clinicalHistory path', () {
      final result = AppRoute.fromPath(AppRoute.clinicalHistory.path);
      expect(result, AppRoute.clinicalHistory);
    });

    test('fromPath returns null for unknown path', () {
      final result = AppRoute.fromPath('/unknown');
      expect(result, isNull);
    });

    test('fromPath returns null for empty path', () {
      final result = AppRoute.fromPath('');
      expect(result, isNull);
    });
  });
}
