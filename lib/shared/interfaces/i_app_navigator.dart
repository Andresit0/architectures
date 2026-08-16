import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';

abstract interface class IAppNavigator {
  void go(AppRoute route, {Object? extra});

  Future<void> push(AppRoute route, {Object? extra});
}
