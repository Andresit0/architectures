import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import '../../../../core/network/dio/dio_wrapper.dart';

import '../../domain/datasources/i_auth_datasource.dart';
import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/token_entity.dart';
import '../mappers/auth_mapper.dart';
import '../dtos/login_response_dto.dart';
import '../dtos/token_dto.dart';

class AuthRemoteDatasourceImpl implements IAuthRemoteDatasource {
  AuthRemoteDatasourceImpl({
    required this._dio,
  });

  final IDioWrapper _dio;

  @override
  Future<LoginResponseEntity> login({
    required String email,
    required String passwordHash,
  }) async {
    final httpResponse = await _dio.post(
      AppUries().login,
      sla: EndpointSla.login,
      body: <String, dynamic>{'email': email, 'passwordHash': passwordHash},
    );
    final response = httpResponse.data!;
    return AuthMapper.loginResponseFromDto(LoginResponseDto.fromJson(response));
  }

  @override
  Future<TokenEntity> refreshToken({required String token}) async {
    final httpResponse = await _dio.post(
      AppUries().refreshToken,
      sla: EndpointSla.login,
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );
    final response = httpResponse.data!;
    return AuthMapper.tokenFromDto(TokenDto.fromJson(response['token'] as Map<String, dynamic>));
  }
}
