part of '_function.lib.dart';

abstract class IServerReachabilityStrategy {
  const IServerReachabilityStrategy();

  /// Returns `true` if the server is reachable (any HTTP response received).
  /// Returns `false` on network error, timeout, or DNS failure.
  /// Does NOT indicate backend health (DB, Redis, etc.).
  Future<bool> check();
}

class NativeSocketReachability extends IServerReachabilityStrategy {
  final String host;
  final int port;
  final Duration timeout;

  NativeSocketReachability({
    required this.host,
    required this.port,
    this.timeout = const Duration(seconds: 5),
  });

  @override
  Future<bool> check() async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}

class HttpReachability extends IServerReachabilityStrategy {
  final Dio _dio;
  final Uri _baseUri;

  HttpReachability({
    required this._dio,
    required this._baseUri,
  });

  @override
  Future<bool> check() async {
    try {
      final response = await _dio.headUri(
        _baseUri,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (_) => true,
        ),
      );
      return response.statusCode != null;
    } catch (_) {
      return false;
    }
  }
}
