import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/app/router/app_router.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';
import 'package:go_router/go_router.dart';

Iterable<({GoRoute route, String path})> _flattenRoutes(
  List<RouteBase> routes, {
  String parentPath = '',
}) sync* {
  for (final base in routes) {
    if (base is GoRoute) {
      final fullPath = base.path.startsWith('/')
          ? base.path
          : '$parentPath/${base.path}'.replaceAll(RegExp('/+'), '/');
      yield (route: base, path: fullPath);
      yield* _flattenRoutes(base.routes, parentPath: fullPath);
    }
  }
}

void main() {
  group('appRoutes', () {
    test('appRoutes returns 2 top-level routes', () {
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

    test('clinical-history route has a nested lab-results child route', () {
      final routes = appRoutes();
      final clinicalHistory = routes[1] as GoRoute;
      final children = clinicalHistory.routes;
      expect(children, hasLength(1));

      final labResults = children.single as GoRoute;
      expect(labResults.path, 'lab-results');
      expect(labResults.name, AppRoute.labResults.name);
    });

    test(
      'every AppRoute value has a matching GoRoute (single source of truth)',
      () {
        final flattened = _flattenRoutes(appRoutes()).toList();
        expect(
          flattened.length,
          AppRoute.values.length,
          reason:
              'la tabla de rutas debe cubrir exactamente el registro AppRoute',
        );

        final routePaths = <String>{};
        final routeNames = <String?>{};
        for (final entry in flattened) {
          routePaths.add(entry.path);
          routeNames.add(entry.route.name);
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
