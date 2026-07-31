enum AppRoute {
  login(path: '/', name: 'login'),
  clinicalHistory(path: '/clinical-history', name: 'clinical-history');

  const AppRoute({
    required this.path,
    required this.name,
  });

  final String path;
  final String name;

  bool get isLoginPath => path == '/';
  bool get isProtectedPath => !isLoginPath;

  static AppRoute? fromPath(String path) {
    for (final route in AppRoute.values) {
      if (route.path == path) return route;
    }
    return null;
  }
}
