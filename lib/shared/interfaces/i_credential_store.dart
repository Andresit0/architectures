abstract interface class ICredentialStore {
  Future<void> saveCredentials({
    required String email,
    required String passwordHash,
  });
  Future<({String email, String passwordHash})?> readCredentials();
  Future<void> deleteCredentials();
}
