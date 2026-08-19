import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' as jwt;

abstract interface class IJwtWrapper {
  Map<String, dynamic>? decodePayload(String token);
}

class JwtWrapper implements IJwtWrapper {
  const JwtWrapper();

  @override
  Map<String, dynamic>? decodePayload(String token) {
    final decoded = jwt.JWT.tryDecode(token);
    if (decoded == null) return null;
    final payload = decoded.payload;
    return payload is Map<String, dynamic> ? payload : null;
  }
}
