import 'package:clean_architecture_sdd_harness/app/di/auth/auth_observer_provider.dart';
import 'package:clean_architecture_sdd_harness/app/router/app_router.dart';
import 'package:clean_architecture_sdd_harness/app/router/guards/auth_guard.dart';
import 'package:clean_architecture_sdd_harness/app/widgets/app_error_screen.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final observer = ref.watch(authenticationObserverProvider);
  const guard = AuthGuard();
  return GoRouter(
    initialLocation: AppRoute.login.path,
    refreshListenable: observer,
    redirect: (context, state) => guard.redirect(
      location: state.matchedLocation,
      from: state.uri.queryParameters['from'],
      isAuthenticated: observer.isAuthenticated,
    ),
    errorBuilder: (context, state) => AppErrorScreen(error: state.error),
    routes: appRoutes(onLogout: () => ref.read(authProvider.notifier).logout()),
  );
});
