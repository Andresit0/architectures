part of '_interceptors.lib.dart';

class AuthInterceptor extends Interceptor {
  final Future<String?> Function() _readToken;

  AuthInterceptor(this._readToken);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}
