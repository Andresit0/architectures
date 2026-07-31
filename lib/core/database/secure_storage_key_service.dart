import 'dart:convert';
import 'dart:math';

import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';

abstract class IDatabaseKeyService {
  Future<String?> readKey();
  Future<void> saveKey(String key);
  Future<void> deleteKey();
  String generateKey();
}

class DatabaseKeyService implements IDatabaseKeyService {

  DatabaseKeyService({ISecureStorageWrapper? storage})
    : _storage = storage ?? const SecureStorageWrapper();
  final ISecureStorageWrapper _storage;
  static const String _keyName = 'db_encryption_key';

  @override
  Future<String?> readKey() => _storage.read(key: _keyName);

  @override
  Future<void> saveKey(String key) => _storage.write(key: _keyName, value: key);

  @override
  Future<void> deleteKey() => _storage.delete(key: _keyName);

  @override
  String generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
