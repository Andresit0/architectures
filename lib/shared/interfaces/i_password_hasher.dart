abstract interface class IPasswordHasher {
  Future<String> hash(String password);
}
