part of '_function.lib.dart';

abstract class ICpDrift {
  Future<({String fullname, String token})?> readSession();
  Future<void> saveSession({required String fullname, required String token});
  Future<void> clearSession();
}

class CpDrift implements ICpDrift {
  CpDrift(this._db, this._keyService, this._encrypter);

  final AppDatabase _db;
  final IDatabaseKeyService _keyService;
  final ICpEncrypt _encrypter;

  String? _cachedKey;

  Future<String> _resolveKey() async {
    if (_cachedKey != null) return _cachedKey!;

    final existing = await _keyService.readKey();
    if (existing != null) {
      _cachedKey = existing;
      return existing;
    }

    await _db.clearSession();

    final newKey = _keyService.generateKey();
    await _keyService.saveKey(newKey);
    _cachedKey = newKey;
    return newKey;
  }

  @override
  Future<({String fullname, String token})?> readSession() async {
    final key = await _resolveKey();
    final row = await _db.readSession();
    if (row == null) return null;

    try {
      final token = _encrypter.decrypt(row.token, key);
      final fullname = _encrypter.decrypt(row.fullname, key);

      if (await CustomFunction.tokenService.isTokenExpired(token)) {
        await _db.clearSession();
        return null;
      }

      return (fullname: fullname, token: token);
    } catch (_) {
      await _db.clearSession();
      return null;
    }
  }

  @override
  Future<void> saveSession({
    required String fullname,
    required String token,
  }) async {
    final key = await _resolveKey();
    await _db.saveSession(
      fullname: _encrypter.encrypt(fullname, key),
      token: _encrypter.encrypt(token, key),
    );
  }

  @override
  Future<void> clearSession() => _db.clearSession();
}
