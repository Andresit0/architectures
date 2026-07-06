part of '_interceptors.lib.dart';

class AuthInterceptor extends Interceptor {
  static void Function()? onForceLogout;

  final Future<String?> Function() _readToken;
  final Future<void> Function(String) _saveToken;
  final Future<({String email, String passwordHash})?> Function()
  _readCredentials;
  final Dio _internalDio;
  final Uri _loginUri;
  final Uri _refreshUri;
  final Future<bool> Function() _checkConnectivity;

  AuthInterceptor({
    required this._readToken,
    required this._saveToken,
    required this._readCredentials,
    required this._internalDio,
    required this._loginUri,
    required this._refreshUri,
    required this._checkConnectivity,
  });

  bool _isRefreshing = false;

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

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    if (_isRefreshing) return handler.next(err);
    _isRefreshing = true;

    try {
      await _attemptRefresh(err, handler);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _attemptRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!await _checkConnectivity()) {
      return handler.next(err);
    }

    try {
      final refreshResult = await _callRefresh();
      if (refreshResult != null) {
        await _saveToken(refreshResult);
        await _retryRequest(err, refreshResult, handler);
        return;
      }
    } on DioException catch (e) {
      if (e.response == null) {
        return handler.next(err);
      }
    } 

    try {
      final creds = await _readCredentials();
      if (creds != null) {
        final reLoginResult = await _callReLogin(email: creds.email, passwordHash: creds.passwordHash);
        if (reLoginResult != null) {
          await _saveToken(reLoginResult);
          await _retryRequest(err, reLoginResult, handler);
          return;
        }
      }
    } on DioException catch (e) {
      if (e.response == null) {
        return handler.next(err);
      }
    }

    AuthInterceptor.onForceLogout?.call();
    handler.next(err);
  }

  Future<String?> _callRefresh() async {
    final token = await _readToken();
    if (token == null) return null;

    try {
      final response = await _internalDio.postUri(
        _refreshUri,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map<String, dynamic>;
        final tokenData = body['token'] as Map<String, dynamic>?;
        return tokenData?['key'] as String?;
      }
      return null;
    } on DioException catch (e) {
      if (e.response == null) rethrow;
      return null; 
    }
  }

  Future<String?> _callReLogin({
    required String email,
    required String passwordHash,
  }) async {
    try {
      final response = await _internalDio.postUri(
        _loginUri,
        data: {'email': email, 'passwordHash': passwordHash},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map<String, dynamic>;
        final tokenData = body['token'] as Map<String, dynamic>?;
        return tokenData?['key'] as String?;
      }
      return null;
    } on DioException catch (e) {
      if (e.response == null) rethrow; 
      return null;
    }
  }

  Future<void> _retryRequest(
    DioException err,
    String newToken,
    ErrorInterceptorHandler handler,
  ) async {
    err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
    try {
      final response = await _internalDio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }
}