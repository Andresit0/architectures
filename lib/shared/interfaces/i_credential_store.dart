abstract interface class ICredentialStore {
  Future<String?> readToken();
  Future<void> saveToken(String value);
  Future<void> saveCredentials({
    required String email,
    required String passwordHash,
  });
  Future<({String email, String passwordHash})?> readCredentials();
  Future<void> deleteCredentials();
  Future<void> deleteAll();
}
