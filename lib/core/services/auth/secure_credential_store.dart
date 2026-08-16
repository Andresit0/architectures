import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/core/services/storage/secure_storage_wrapper.dart';

class SecureCredentialStore implements ICredentialStore {
  const SecureCredentialStore({required this._storage});

  final ISecureStorageWrapper _storage;
  static const String _emailKey = 'tudesarrollador_login_email';
  static const String _passwordHashKey = 'tudesarrollador_login_pwhash';

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
}
