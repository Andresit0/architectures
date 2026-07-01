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
        if (authenticated && isLoginRoute) return '/dashboard';
        return null;
      },
      routes: routes,
    );
    CustomFunction.goRouter = CpGoRouter(router);
    return router;
  }

  @override
  void go(String location, {Object? extra}) {
    try {
      _router.go(location, extra: extra);
    } catch (e) {
      throw CustomExceptions.goRouter('go_router.go error: ${e.toString()}');
    }
  }

  @override
  void push(String location, {Object? extra}) {
    try {
      _router.push(location, extra: extra);
    } catch (e) {
      throw CustomExceptions.goRouter('go_router.push error: ${e.toString()}');
    }
  }

  @override
  void goNamed(String name, {Map<String, String>? params, Object? extra}) {
    try {
      _router.goNamed(name, pathParameters: params ?? {}, extra: extra);
    } catch (e) {
      throw CustomExceptions.goRouter(
        'go_router.goNamed error: ${e.toString()}',
      );
    }
  }

  @override
  void pushNamed(String name, {Map<String, String>? params, Object? extra}) {
    try {
      _router.pushNamed(name, pathParameters: params ?? {}, extra: extra);
    } catch (e) {
      throw CustomExceptions.goRouter(
        'go_router.pushNamed error: ${e.toString()}',
      );
    }
  }

  @override
  void pop() {
    try {
      _router.pop();
    } catch (e) {
      throw CustomExceptions.goRouter('go_router.pop error: ${e.toString()}');
    }
  }

  @override
  bool canPop() {
    try {
      return _router.canPop();
    } catch (e) {
      CustomFunction.logger.error('go_router.canPop error: ${e.toString()}');
      return false;
    }
  }

  @override
  void replace(String location, {Object? extra}) {
    try {
      _router.replace(location, extra: extra);
    } catch (e) {
      throw CustomExceptions.goRouter(
        'go_router.replace error: ${e.toString()}',
      );
    }
  }
}
