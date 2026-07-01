part of '_configs.lib.dart';

class AppUries {
  final String host = CustomConfigs.vars.host;
  final int port = CustomConfigs.vars.port;
  // Uri get _base => Uri(scheme: 'http', host: host, port: port);

  // final String _userPath = '/user';
  // Uri get dashboard => _base.replace(path: '$_userPath/dashboard');
}
