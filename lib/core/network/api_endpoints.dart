import '../config/app_environment.dart';

class AppUries {
  String get host => AppEnvironment.current.host;
  int get port => AppEnvironment.current.port;
  Uri get _base => Uri(
    scheme: AppEnvironment.current.useHttps ? 'https' : 'http',
    host: host,
    port: port,
  );

  final String _userPath = '/user';
  Uri get login => _base.replace(path: '$_userPath/login');
  Uri get refreshToken => _base.replace(path: '$_userPath/refreshtoken');
}
