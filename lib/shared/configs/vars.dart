part of '_configs.lib.dart';

class Vars {
  final String appName = 'tudesarrollador';

  final String host = const String.fromEnvironment(
    'API_HOST',
    defaultValue: 'localhost',
  );

  final bool isReleaseMode = const bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  final int port = const int.fromEnvironment('API_PORT', defaultValue: 5111);

  final bool useMockRepository = const bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );
}
