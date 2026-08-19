enum AppRoute {
  login(path: '/', name: 'login'),
  clinicalHistory(path: '/clinical-history', name: 'clinical-history'),
  labResults(path: '/clinical-history/lab-results', name: 'lab-results');

  const AppRoute({required this.path, required this.name})
    : assert(path != '', 'AppRoute path must not be empty'),
      assert(name != '', 'AppRoute name must not be empty');

  final String path;
  final String name;

  static AppRoute? fromPath(String path) {
    for (final route in AppRoute.values) {
      if (route.path == path) return route;
    }
    return null;
  }
}
