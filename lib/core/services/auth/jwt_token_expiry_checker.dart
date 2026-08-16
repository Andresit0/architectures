import 'package:clean_architecture_sdd_harness/core/services/auth/jwt_wrapper.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

class JwtTokenExpiryChecker implements ITokenVerifier {
  const JwtTokenExpiryChecker({required this._jwtWrapper});

  final IJwtWrapper _jwtWrapper;

  @override
  Future<bool> isExpired(String token) async {
    final payload = _jwtWrapper.decodePayload(token);
    if (payload == null) return true;
    final exp = payload['exp'];
    if (exp == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return DateTime.now().isAfter(expiry);
  }
}
