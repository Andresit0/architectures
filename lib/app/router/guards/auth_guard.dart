import 'package:clean_architecture_sdd_harness/app/router/app_route.dart';

class AuthGuard {
  const AuthGuard();

  String? redirect({
    required String location,
    required bool isAuthenticated,
  }) {
    final route = AppRoute.fromPath(location);
    final isLoginRoute = route == AppRoute.login;
    if (!isAuthenticated && !isLoginRoute) return AppRoute.login.path;
    if (isAuthenticated && isLoginRoute) {
      return AppRoute.clinicalHistory.path;
    }
    return null;
  }
}
