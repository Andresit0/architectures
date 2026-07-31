import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' as jwt;

abstract interface class IJwtWrapper {
  bool verifySignature(String token, String secret);
}

class JwtWrapper implements IJwtWrapper {
  const JwtWrapper();

  @override
  bool verifySignature(String token, String secret) {
    try {
      jwt.JWT.verify(token, jwt.SecretKey(secret));
      return true;
    } catch (_) {
      return false;
    }
  }
}
