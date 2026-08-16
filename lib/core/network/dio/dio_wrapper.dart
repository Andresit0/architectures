import 'dart:async' show TimeoutException;

import 'package:clean_architecture_sdd_harness/shared/exceptions/api_exception.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/no_connection_exception.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/server_unreachable_exception.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/timeout_exception.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/unexpected_response_exception.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/internet_service.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_multipart_builder.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_response_parser.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/i_multipart_file.dart';
import 'package:clean_architecture_sdd_harness/core/network/interceptors/_interceptors.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/security/certificate_pinner.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/utils/uri_utils.dart';
import 'package:clean_architecture_sdd_harness/shared/error/retry_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

enum _HttpMethod { get, post, patch, delete, put, multipart }

abstract class IDioWrapper {
  Future<HttpResponse<Map<String, dynamic>>> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    String? type,
    Map<String, String>? pathParams,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  });

  Future<HttpResponse<Map<String, dynamic>>> get(
    Uri url, {
    Map<String, String>? headers,
    String? type,
    Map<String, String>? pathParams,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  });

  Future<HttpResponse<Map<String, dynamic>>> patch({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  });

  Future<HttpResponse<Map<String, dynamic>>> delete({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  });

  Future<HttpResponse<Map<String, dynamic>>> put({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  });

  Future<HttpResponse<Map<String, dynamic>>> multiFiles({
    required Uri uri,
    required List<IMultipartFile> fileList,
    required String type,
    List<Map<String, String>>? fields,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  });

  void addAuthInterceptor(
    Future<RetryResult> Function() onRetry, {
    required VoidCallback onForceLogout,
  });
}

class DioWrapper implements IDioWrapper {
  DioWrapper(
    this._internetService, [
    Dio? dio,
    ICertificatePinner? certificatePinner,
    IDioMultipartBuilder? multipartBuilder,
    IDioResponseParser? responseParser,
    ConnectionProfile? profile,
  ]) : _dio = dio ?? Dio(),
       _certificatePinner =
           certificatePinner ?? CertificatePinner(pinnedCertificates: const []),
       _multipartBuilder = multipartBuilder ?? const DioMultipartBuilder(),
       _responseParser = responseParser ?? const DioResponseParser(),
       _profile = profile ?? ConnectionProfile.standard {
    _certificatePinner.apply(_dio);
    _dio.options.connectTimeout = _profile.connectTimeout;
    _dio.options.receiveTimeout = _profile.receiveTimeout;
    _dio.options.sendTimeout = _profile.sendTimeout;
  }
  final Dio _dio;
  final IInternetService _internetService;
  final ICertificatePinner _certificatePinner;
  final IDioMultipartBuilder _multipartBuilder;
  final IDioResponseParser _responseParser;
  final ConnectionProfile _profile;

  @override
  void addAuthInterceptor(
    Future<RetryResult> Function() onRetry, {
    required VoidCallback onForceLogout,
  }) {
    final internalDio = Dio();
    _dio.interceptors.add(
      CustomInterceptors.auth(
        onRetry: onRetry,
        internalDio: internalDio,
        onForceLogout: onForceLogout,
      ),
    );
  }

  Future<void> _checkConnectivity() async {
    if (!await _internetService.isConnected()) {
      throw NoConnectionException();
    }
    if (!await _internetService.isServerReachable()) {
      throw ServerUnreachableException();
    }
  }

  Future<HttpResponse<Map<String, dynamic>>> _request({
    required _HttpMethod method,
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
        case _HttpMethod.get:
          response = await _dio
              .getUri<dynamic>(uri, options: requestOptions)
              .timeout(effectiveTimeout);
        case _HttpMethod.post:
          response = await _dio
              .postUri<dynamic>(uri, data: body, options: requestOptions)
              .timeout(effectiveTimeout);
        case _HttpMethod.patch:
          response = await _dio
              .patchUri<dynamic>(uri, data: body, options: requestOptions)
              .timeout(effectiveTimeout);
        case _HttpMethod.delete:
          response = await _dio
              .deleteUri<dynamic>(uri, data: body, options: requestOptions)
              .timeout(effectiveTimeout);
        case _HttpMethod.put:
          response = await _dio
              .putUri<dynamic>(uri, data: body, options: requestOptions)
              .timeout(effectiveTimeout);
        case _HttpMethod.multipart:
          final formData = await _multipartBuilder.build(
            fields: fields,
            fileList: fileList?.cast<Object?>(),
          );
          response = await _dio
              .postUri<dynamic>(uri, data: formData, options: requestOptions)
              .timeout(effectiveTimeout);
      }

      final httpResponse = _responseParser.parse(
        response: response,
        type: type,
        returnDioResponse: returnDioResponse,
      );
      return httpResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        if (sla.retry.retryOnTimeout && attempt < sla.retry.maxRetries) {
          await Future<void>.delayed(sla.retry.baseDelay);
          return _request(
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
          );
        }
        throw AppTimeoutException(
          endpoint: uri.toString(),
          configuredTimeout: sla.timeout,
          attemptNumber: attempt,
        );
      }
      if (e.response != null) {
        throw ApiException(e.response!.statusCode ?? 0);
      }
      throw NoConnectionException();
    } on TimeoutException catch (_) {
      if (sla.retry.retryOnTimeout && attempt < sla.retry.maxRetries) {
        await Future<void>.delayed(sla.retry.baseDelay);
        return _request(
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
        );
      }
      throw AppTimeoutException(
        endpoint: uri.toString(),
        configuredTimeout: sla.timeout,
        attemptNumber: attempt,
      );
    } catch (error) {
      throw UnexpectedResponseException('Dio internal error: $error');
    }
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    String? type,
    Map<String, String>? pathParams,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  }) async {
    url = UriUtils.replacePathParams(url, pathParams);
    return _request(
      method: _HttpMethod.post,
      uri: url,
      headers: headers,
      body: body,
      returnDioResponse: returnDioResponse,
      sla: sla,
    );
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> get(
    Uri url, {
    Map<String, String>? headers,
    String? type,
    Map<String, String>? pathParams,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  }) async {
    url = UriUtils.replacePathParams(url, pathParams);
    return _request(
      method: _HttpMethod.get,
      uri: url,
      type: type,
      headers: headers,
      returnDioResponse: returnDioResponse,
      sla: sla,
    );
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> patch({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  }) async {
    uri = UriUtils.replacePathParams(uri, pathParams);
    return _request(
      method: _HttpMethod.patch,
      uri: uri,
      headers: headers,
      body: body,
      returnDioResponse: returnDioResponse,
      sla: sla,
    );
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> delete({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  }) async {
    uri = UriUtils.replacePathParams(uri, pathParams);
    return _request(
      method: _HttpMethod.delete,
      uri: uri,
      headers: headers,
      body: body,
      returnDioResponse: returnDioResponse,
      sla: sla,
    );
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> put({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  }) async {
    uri = UriUtils.replacePathParams(uri, pathParams);
    return _request(
      method: _HttpMethod.put,
      uri: uri,
      headers: headers,
      body: body,
      returnDioResponse: returnDioResponse,
      sla: sla,
    );
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> multiFiles({
    required Uri uri,
    required List<IMultipartFile> fileList,
    required String type,
    List<Map<String, String>>? fields,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    bool returnDioResponse = false,
    EndpointSla sla = EndpointSla.unknown,
  }) async {
    uri = UriUtils.replacePathParams(uri, pathParams);
    return _request(
      method: _HttpMethod.multipart,
      type: type,
      uri: uri,
      fileList: fileList,
      headers: headers,
      body: body,
      fields: fields,
      returnDioResponse: returnDioResponse,
      sla: sla,
    );
  }
}
