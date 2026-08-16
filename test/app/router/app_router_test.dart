import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/app/router/app_router.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';
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

    test(
      'second route has path /clinical-history and name clinical-history',
      () {
        final routes = appRoutes();
        final second = routes[1] as GoRoute;
        expect(second.path, '/clinical-history');
        expect(second.name, 'clinical-history');
      },
    );

    test(
      'every AppRoute value has a matching GoRoute (single source of truth)',
      () {
        final routes = appRoutes().whereType<GoRoute>();
        expect(
          routes.length,
          AppRoute.values.length,
          reason:
              'la tabla de rutas debe cubrir exactamente el registro AppRoute',
        );

        final routePaths = <String>{};
        final routeNames = <String?>{};
        for (final route in routes) {
          routePaths.add(route.path);
          routeNames.add(route.name);
        }

        for (final appRoute in AppRoute.values) {
          expect(
            routePaths,
            contains(appRoute.path),
            reason:
                'falta GoRoute para ${appRoute.name} (path ${appRoute.path})',
          );
          expect(
            routeNames,
            contains(appRoute.name),
            reason: 'falta nombre go_router para ${appRoute.name}',
          );
        }
      },
    );
  });
}
