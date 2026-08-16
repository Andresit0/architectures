import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';
import 'package:go_router/go_router.dart';

class GoRouterNavigator implements IAppNavigator {
  GoRouterNavigator(this._router);

  final GoRouter _router;

  @override
  void go(AppRoute route, {Object? extra}) =>
      _router.go(route.path, extra: extra);

  @override
  Future<void> push(AppRoute route, {Object? extra}) async {
    await _router.push(route.path, extra: extra);
  }
}
