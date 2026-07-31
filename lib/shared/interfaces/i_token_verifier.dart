abstract interface class ITokenVerifier {
  Future<bool> isExpired(String token);
  Map<String, dynamic>? decodePayload(String token);
  bool verifySignature(String token, String secret);
}
