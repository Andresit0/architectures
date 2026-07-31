abstract interface class ITokenStore {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> delete();
}
