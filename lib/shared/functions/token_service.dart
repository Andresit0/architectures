part of '_function.lib.dart';

abstract class ITokenService {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> delete();
  Future<void> saveRefreshToken(String token);
  Future<String?> readRefreshToken();
  Future<void> deleteRefreshToken();
  Future<bool> isTokenExpired(String token);
  Map<String, dynamic>? decodeJwtPayload(String token);
}

class TokenService implements ITokenService {
  TokenService({ICpFlutterSecureStorage? storage})
    : _storage = storage ?? CpFlutterSecureStorage();

  final ICpFlutterSecureStorage _storage;
  static const String _key = 'tudesarrollador_auth_token';
  static const String _refreshKey = 'tudesarrollador_refresh_token';

  String? _cachedToken;
  String? _cachedRefreshToken;

  @override
  Future<bool> isTokenExpired(String token) async {
    final payload = decodeJwtPayload(token);
    if (payload == null) return true;
    final exp = payload['exp'];
    if (exp == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return DateTime.now().isAfter(expiry);
  }

  @override
  Map<String, dynamic>? decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
        case 3:
          payload += '=';
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(String token) async {
    _cachedToken = token;
    await _storage.write(key: _key, value: token);
  }

  @override
  Future<String?> read() async =>
      _cachedToken ??= await _storage.read(key: _key);

  @override
  Future<void> delete() async {
    _cachedToken = null;
    await _storage.delete(key: _key);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    _cachedRefreshToken = token;
    await _storage.write(key: _refreshKey, value: token);
  }

  @override
  Future<String?> readRefreshToken() async =>
      _cachedRefreshToken ??= await _storage.read(key: _refreshKey);

  @override
  Future<void> deleteRefreshToken() async {
    _cachedRefreshToken = null;
    await _storage.delete(key: _refreshKey);
  }
}
