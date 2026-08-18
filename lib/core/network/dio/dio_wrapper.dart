import 'package:clean_architecture_sdd_harness/core/network/connectivity/internet_service.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_multipart_builder.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_response_parser.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/error_mapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/i_multipart_file.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/request_executor.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/retry_executor.dart';
import 'package:clean_architecture_sdd_harness/core/network/interceptors/_interceptors.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/security/certificate_pinner.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/utils/uri_utils.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

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
    required Future<String?> Function() getToken,
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
    IErrorMapper? errorMapper,
    IRetryExecutor? retryExecutor,
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
    _requestExecutor = RequestExecutor(
      dio: _dio,
      internetService: _internetService,
      multipartBuilder: _multipartBuilder,
      responseParser: _responseParser,
      errorMapper: errorMapper ?? const ErrorMapper(),
      retryExecutor: retryExecutor ?? const RetryExecutor(),
    );
  }

  final Dio _dio;
  final IInternetService _internetService;
  final ICertificatePinner _certificatePinner;
  final IDioMultipartBuilder _multipartBuilder;
  final IDioResponseParser _responseParser;
  final ConnectionProfile _profile;
  late final IRequestExecutor _requestExecutor;

  @override
  void addAuthInterceptor(
    Future<RetryResult> Function() onRetry, {
    required VoidCallback onForceLogout,
    required Future<String?> Function() getToken,
  }) {
    final internalDio = Dio();
    _dio.interceptors.add(
      CustomInterceptors.auth(
        onRetry: onRetry,
        internalDio: internalDio,
        onForceLogout: onForceLogout,
        getToken: getToken,
      ),
    );
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
    return _requestExecutor.execute(
      method: HttpMethod.post,
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
    return _requestExecutor.execute(
      method: HttpMethod.get,
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
    return _requestExecutor.execute(
      method: HttpMethod.patch,
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
    return _requestExecutor.execute(
      method: HttpMethod.delete,
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
    return _requestExecutor.execute(
      method: HttpMethod.put,
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
    return _requestExecutor.execute(
      method: HttpMethod.multipart,
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
