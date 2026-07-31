import 'dart:convert';

import 'package:clean_architecture_sdd_harness/core/services/auth/jwt_wrapper.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_token_verifier.dart';

class JwtTokenExpiryChecker implements ITokenVerifier {
  const JwtTokenExpiryChecker({required this._jwtWrapper});

  final IJwtWrapper _jwtWrapper;

  @override
  Future<bool> isExpired(String token) async {
    final payload = decodePayload(token);
    if (payload == null) return true;
    final exp = payload['exp'];
    if (exp == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return DateTime.now().isAfter(expiry);
  }

  @override
  Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
        case 3:
          payload += '=';
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  bool verifySignature(String token, String secret) {
    return _jwtWrapper.verifySignature(token, secret);
  }
}
