import '../../../../shared/configs/_configs.lib.dart';
import '../../../../shared/functions/_function.lib.dart';
import '../../../../shared/jsons/_jsons.lib.dart';

import '../../domain/datasources/i_auth_datasource.dart';
import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/token_entity.dart';
import '../mappers/auth_mapper.dart';

class AuthRemoteDatasourceImpl implements IAuthRemoteDatasource {
  AuthRemoteDatasourceImpl({required this._dio});

  final ICpDio _dio;

  @override
  Future<LoginResponseEntity> login({
    required String email,
    required String passwordHash,
  }) async {
    if (CustomConfigs.vars.useMockRepository) {
      final json = CustomJsons.authJson.loginResponse200;
      return AuthMapper.loginResponseFromJson(json);
    }
    final response = await _dio.post(
      CustomConfigs.uries.login,
      body: <String, dynamic>{'email': email, 'passwordHash': passwordHash},
    ) as Map<String, dynamic>;
    return AuthMapper.loginResponseFromJson(response);
  }

  @override
  Future<TokenEntity> refreshToken({required String token}) async {
    final response = await _dio.post(
      CustomConfigs.uries.refreshToken,
      headers: <String, String>{'Authorization': 'Bearer $token'},
    ) as Map<String, dynamic>;
    return AuthMapper.refreshTokenFromJson(response);
  }
}
