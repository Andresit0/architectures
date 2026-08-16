abstract interface class ITokenVerifier {
  Future<bool> isExpired(String token);
}
