abstract interface class IPasswordHasher {
  Future<String> hash(String password);
  Future<bool> verify(String password, String hash);
}
