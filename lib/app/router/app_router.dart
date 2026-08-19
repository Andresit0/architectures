import 'package:clean_architecture_sdd_harness/features/auth/presentation/screens/login_screen.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/presentation/screens/clinical_history_screen.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/presentation/screens/lab_results_screen.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> appRoutes({Future<void> Function()? onLogout}) => [
  GoRoute(
    path: AppRoute.login.path,
    name: AppRoute.login.name,
    builder: (_, _) => const LoginScreen(),
  ),
  GoRoute(
    path: AppRoute.clinicalHistory.path,
    name: AppRoute.clinicalHistory.name,
    builder: (_, _) => ClinicalHistoryScreen(onLogout: onLogout),
    routes: [
      GoRoute(
        path: AppRoute.labResults.path.replaceFirst(
          '${AppRoute.clinicalHistory.path}/',
          '',
        ),
        name: AppRoute.labResults.name,
        builder: (_, _) => const LabResultsScreen(),
      ),
    ],
  ),
];
