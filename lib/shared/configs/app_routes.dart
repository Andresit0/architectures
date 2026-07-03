part of '_configs.lib.dart';

class Routes {
  final List<RouteBase> goRouter = [
    GoRoute(
      path: '/',
      name: CpGoRouter.nameLogin,
      builder: (_,_) => const LoginScreen(),
    ),
    GoRoute(
      path: '/${CpGoRouter.nameClinicalHistory}',
      name: CpGoRouter.nameClinicalHistory,
      builder: (_, _) => const ClinicalHistoryPlaceholderScreen(),//TODO(Andrés Riofrío): it is a mock(should be reemplaced)
    ),
  ];
}
