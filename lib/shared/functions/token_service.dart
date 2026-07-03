part of '_function.lib.dart';

abstract class ITokenService {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> delete();
  Future<bool> isTokenExpired(String token);
  Map<String, dynamic>? decodeJwtPayload(String token);
  Future<void> saveCredentials({required String email, required String passwordHash});
  Future<({String email, String passwordHash})?> readCredentials();
  Future<void> deleteCredentials();
  Future<void> deleteAll();
}

class TokenService implements ITokenService {
  TokenService({ICpFlutterSecureStorage? storage})
    : _storage = storage ?? CpFlutterSecureStorage();

  final ICpFlutterSecureStorage _storage;
  static const String _key = 'tudesarrollador_auth_token';
  static const String _emailKey = 'tudesarrollador_login_email';
  static const String _passwordHashKey = 'tudesarrollador_login_pwhash';

  String? _cachedToken;

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
  Future<void> saveCredentials({
    required String email,
    required String passwordHash,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordHashKey, value: passwordHash);
  }

  @override
  Future<({String email, String passwordHash})?> readCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final pwhash = await _storage.read(key: _passwordHashKey);
    if (email == null || pwhash == null) return null;
    return (email: email, passwordHash: pwhash);
  }

  @override
  Future<void> deleteCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordHashKey);
  }

  @override
  Future<void> deleteAll() async {
    _cachedToken = null;
    await _storage.deleteAll();
  }
}
