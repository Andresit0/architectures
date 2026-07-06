part of '_configs.lib.dart';

class AppUries {
  final String host = CustomConfigs.vars.host;
  final int port = CustomConfigs.vars.port;
  Uri get _base => Uri(
    scheme: CustomConfigs.vars.useHttps ? 'https' : 'http',
    host: host,
    port: port,
  );

  final String _userPath = '/user';
  Uri get login => _base.replace(path: '$_userPath/login');
  Uri get refreshToken => _base.replace(path: '$_userPath/refreshtoken');
}
