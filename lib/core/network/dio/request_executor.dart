import 'dart:async' show TimeoutException;

import 'package:dio/dio.dart';

import 'package:clean_architecture_sdd_harness/core/network/connectivity/internet_service.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_multipart_builder.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_response_parser.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/error_mapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/i_multipart_file.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/retry_executor.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

enum HttpMethod { get, post, patch, delete, put, multipart }

abstract interface class IRequestExecutor {
  Future<HttpResponse<Map<String, dynamic>>> execute({
    required HttpMethod method,
    required Uri uri,
    String? type,
    Map<String, String>? headers,
    List<Map<String, String>>? fields,
    List<IMultipartFile>? fileList,
    Object? body,
    bool returnDioResponse = false,
    required EndpointSla sla,
    int attempt = 1,
  });
}

class RequestExecutor implements IRequestExecutor {
  const RequestExecutor({
    required this._dio,
    required this._internetService,
    required this._multipartBuilder,
    required this._responseParser,
    required this._errorMapper,
    required this._retryExecutor,
  });

  final Dio _dio;
  final IInternetService _internetService;
  final IDioMultipartBuilder _multipartBuilder;
  final IDioResponseParser _responseParser;
  final IErrorMapper _errorMapper;
  final IRetryExecutor _retryExecutor;

  Future<void> _checkConnectivity() async {
    if (!await _internetService.isConnected()) {
      throw NoConnectionException();
    }
    if (!await _internetService.isServerReachable()) {
      throw ServerUnreachableException();
    }
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> execute({
    required HttpMethod method,
    required Uri uri,
    String? type,
    Map<String, String>? headers,
    List<Map<String, String>>? fields,
    List<IMultipartFile>? fileList,
    Object? body,
    bool returnDioResponse = false,
    required EndpointSla sla,
    int attempt = 1,
  }) async {
    try {
      await _checkConnectivity();
      final effectiveTimeout = sla.timeout;
      Response<dynamic> response;
      final requestOptions =
          (type == 'bytes' ||
              (headers != null && headers['Content-Type'] == 'application/pdf'))
          ? Options(headers: headers, responseType: ResponseType.bytes)
          : Options(headers: headers);

      switch (method) {
        case HttpMethod.get:
          response = await _dio
              .getUri<dynamic>(uri, options: requestOptions)
              .timeout(effectiveTimeout);
        case HttpMethod.post:
          response = await _dio
              .postUri<dynamic>(uri, data: body, options: requestOptions)
              .timeout(effectiveTimeout);
        case HttpMethod.patch:
          response = await _dio
              .patchUri<dynamic>(uri, data: body, options: requestOptions)
              .timeout(effectiveTimeout);
        case HttpMethod.delete:
          response = await _dio
              .deleteUri<dynamic>(uri, data: body, options: requestOptions)
              .timeout(effectiveTimeout);
        case HttpMethod.put:
          response = await _dio
              .putUri<dynamic>(uri, data: body, options: requestOptions)
              .timeout(effectiveTimeout);
        case HttpMethod.multipart:
          final formData = await _multipartBuilder.build(
            fields: fields,
            fileList: fileList?.cast<Object?>(),
          );
          response = await _dio
              .postUri<dynamic>(uri, data: formData, options: requestOptions)
              .timeout(effectiveTimeout);
      }

      return _responseParser.parse(
        response: response,
        type: type,
        returnDioResponse: returnDioResponse,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return _retryExecutor.retryOrTimeout(
          retryOnTimeout: sla.retry.retryOnTimeout,
          maxRetries: sla.retry.maxRetries,
          baseDelay: sla.retry.baseDelay,
          attempt: attempt,
          uri: uri,
          timeout: sla.timeout,
          reExecute: () => execute(
            method: method,
            uri: uri,
            type: type,
            headers: headers,
            fields: fields,
            fileList: fileList,
            body: body,
            returnDioResponse: returnDioResponse,
            sla: sla,
            attempt: attempt + 1,
          ),
        );
      }
      if (e.response != null) {
        throw ApiException(e.response!.statusCode ?? 0);
      }
      if (e.type == DioExceptionType.connectionError) {
        throw NoConnectionException();
      }
      if (_errorMapper.isBrowserNetworkFailure(e)) {
        throw NoConnectionException();
      }
      throw UnexpectedResponseException(
        'Unhandled DioException type: ${e.type}',
      );
    } on TimeoutException catch (_) {
      return _retryExecutor.retryOrTimeout(
        retryOnTimeout: sla.retry.retryOnTimeout,
        maxRetries: sla.retry.maxRetries,
        baseDelay: sla.retry.baseDelay,
        attempt: attempt,
        uri: uri,
        timeout: sla.timeout,
        reExecute: () => execute(
          method: method,
          uri: uri,
          type: type,
          headers: headers,
          fields: fields,
          fileList: fileList,
          body: body,
          returnDioResponse: returnDioResponse,
          sla: sla,
          attempt: attempt + 1,
        ),
      );
    } on Exception catch (error) {
      throw switch (error) {
        UnexpectedResponseException() ||
        NoConnectionException() ||
        ServerUnreachableException() => error,
        _ => const UnexpectedResponseException('Unexpected internal error'),
      };
    }
  }
}
