import 'package:clean_architecture_sdd_harness/app/router/app_route.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/screens/clinical_history_placeholder_screen.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/screens/login_screen.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> appRoutes() => [
  GoRoute(
    path: AppRoute.login.path,
    name: AppRoute.login.name,
    builder: (_, _) => const LoginScreen(),
  ),
  GoRoute(
    path: AppRoute.clinicalHistory.path,
    name: AppRoute.clinicalHistory.name,
    builder: (_, _) => const ClinicalHistoryPlaceholderScreen(),
  ),
];
