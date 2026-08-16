import 'package:clean_architecture_sdd_harness/core/services/storage/secure_storage_wrapper.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

class SecureTokenStore implements ITokenStore {
  SecureTokenStore({required this._storage});

  final ISecureStorageWrapper _storage;
  static const String _key = 'tudesarrollador_auth_token';

  String? _cachedToken;

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
}
