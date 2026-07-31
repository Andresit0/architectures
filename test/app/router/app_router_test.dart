import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/app/router/app_router.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('appRoutes', () {
    test('appRoutes returns 2 routes', () {
      final routes = appRoutes();
      expect(routes.length, 2);
    });

    test('first route has path / and name login', () {
      final routes = appRoutes();
      final first = routes[0] as GoRoute;
      expect(first.path, '/');
      expect(first.name, 'login');
    });

    test('second route has path /clinical-history and name clinical-history', () {
      final routes = appRoutes();
      final second = routes[1] as GoRoute;
      expect(second.path, '/clinical-history');
      expect(second.name, 'clinical-history');
    });
  });
}
