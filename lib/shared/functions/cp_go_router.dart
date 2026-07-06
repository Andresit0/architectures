part of '_function.lib.dart';

abstract class ICpGoRouter {
  void go(String location, {Object? extra});
  void push(String location, {Object? extra});
  void goNamed(String name, {Map<String, String>? params, Object? extra});
  void pushNamed(String name, {Map<String, String>? params, Object? extra});
  void pop();
  bool canPop();
  void replace(String location, {Object? extra});
}

class CpGoRouter implements ICpGoRouter {
  final GoRouter _router;
  static const String nameLogin = 'login';
  static const String nameClinicalHistory = 'clinical-history';

  CpGoRouter(this._router);

  static GoRouter create({
    required Listenable refreshListenable,
    required List<RouteBase> routes,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final authenticated =
            (refreshListenable as GoRouterListenable).isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/';
        if (!authenticated && !isLoginRoute) return '/';
        if (authenticated && isLoginRoute) return '/$nameClinicalHistory';
        return null;
      },
      routes: routes,
    );
    CustomFunction.goRouter = CpGoRouter(router);
    return router;
  }

  @override
  void go(String location, {Object? extra}) => _router.go(location, extra: extra);

  @override
  void push(String location, {Object? extra}) => _router.push(location, extra: extra);

  @override
  void goNamed(String name, {Map<String, String>? params, Object? extra}) =>
      _router.goNamed(name, pathParameters: params ?? {}, extra: extra);

  @override
  void pushNamed(String name, {Map<String, String>? params, Object? extra}) =>
      _router.pushNamed(name, pathParameters: params ?? {}, extra: extra);

  @override
  void pop() => _router.pop();

  @override
  bool canPop() => _router.canPop();

  @override
  void replace(String location, {Object? extra}) => _router.replace(location, extra: extra);
}
