import 'package:clean_architecture_sdd_harness/app/di/auth/auth_provider.dart';
import 'package:clean_architecture_sdd_harness/app/router/app_router.dart';
import 'package:clean_architecture_sdd_harness/app/router/guards/auth_guard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final observer = ref.watch(authenticationObserverProvider);
  const guard = AuthGuard();
  return GoRouter(
    initialLocation: '/',
    refreshListenable: observer as Listenable,
    redirect: (context, state) => guard.redirect(
      location: state.matchedLocation,
      isAuthenticated: observer.isAuthenticated,
    ),
    routes: appRoutes(),
  );
});
