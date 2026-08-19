import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

import 'package:clean_architecture_sdd_harness/features/auth/domain/datasources/i_auth_remote_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/dtos/_dtos.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/mappers/auth_mapper.dart';

class AuthRemoteDatasourceImpl implements IAuthRemoteDatasource {
  AuthRemoteDatasourceImpl({required this._dio, required this._appUries});

  final IDioWrapper _dio;
  final IEndpointConfig _appUries;

  @override
  Future<LoginResponseEntity> login({
    required String email,
    required String passwordHash,
  }) async {
    final httpResponse = await _dio.post(
      _appUries.login,
      sla: EndpointSla.login,
      body: <String, dynamic>{'email': email, 'passwordHash': passwordHash},
    );
    final response = _requireJsonMap(
      httpResponse.data,
      'login response must be a JSON object',
    );
    return AuthMapper.loginResponseFromDto(LoginResponseDto.fromJson(response));
  }

  @override
  Future<TokenEntity> refreshToken({required String token}) async {
    final httpResponse = await _dio.post(
      _appUries.refreshToken,
      sla: EndpointSla.login,
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );
    final response = _requireJsonMap(
      httpResponse.data,
      'refreshToken response must be a JSON object',
    );
    final tokenData = _requireJsonMap(
      response['token'],
      'refreshToken response must contain a token object',
    );
    return AuthMapper.tokenFromDto(TokenDto.fromJson(tokenData));
  }

  Map<String, dynamic> _requireJsonMap(Object? data, String message) {
    if (data is! Map<String, dynamic>) {
      throw UnexpectedResponseException(message);
    }
    return data;
  }
}
