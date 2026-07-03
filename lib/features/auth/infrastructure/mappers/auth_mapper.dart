import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/token_entity.dart';

class AuthMapper {
  static LoginResponseEntity loginResponseFromJson(Map<String, dynamic> json) {
    return LoginResponseEntity.fromJson(json);
  }

  static TokenEntity refreshTokenFromJson(Map<String, dynamic> json) {
    return TokenEntity.fromJson(json['token'] as Map<String, dynamic>);
  }
}
