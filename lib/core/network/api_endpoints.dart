import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_environment.dart';
import '../config/environment_provider.dart';

abstract interface class IEndpointConfig {
  Uri get login;
  Uri get refreshToken;
  Uri get clinicalHistory;
  Uri get labResults;
}

class AppUris implements IEndpointConfig {
  const AppUris({required this.env});

  final AppEnvironment env;

  static const String _userPath = '/user';

  Uri get _base => Uri(
    scheme: env.useHttps ? 'https' : 'http',
    host: env.host,
    port: env.port,
  );

  @override
  Uri get login => _base.replace(path: '$_userPath/login');

  @override
  Uri get refreshToken => _base.replace(path: '$_userPath/refreshtoken');

  @override
  Uri get clinicalHistory => _base.replace(path: '$_userPath/clinical-history');

  @override
  Uri get labResults =>
      _base.replace(path: '$_userPath/clinical-history/lab-results');
}

final appUriesProvider = Provider<IEndpointConfig>(
  (ref) => AppUris(env: ref.watch(environmentProvider)),
);
