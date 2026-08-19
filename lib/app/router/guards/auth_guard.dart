import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';

class AuthGuard {
  const AuthGuard();

  String? redirect({
    required String location,
    required bool isAuthenticated,
    String? from,
  }) {
    if (location.isEmpty) return null;
    final isLoginRoute = location == AppRoute.login.path;

    if (!isAuthenticated && !isLoginRoute) {
      return '${AppRoute.login.path}?from=${Uri.encodeComponent(location)}';
    }

    if (isAuthenticated && isLoginRoute) {
      final canRestore =
          from != null &&
          from.isNotEmpty &&
          from != AppRoute.login.path &&
          AppRoute.fromPath(from) != null;
      return canRestore ? from : AppRoute.clinicalHistory.path;
    }

    return null;
  }
}
