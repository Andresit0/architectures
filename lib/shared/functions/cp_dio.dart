part of '_function.lib.dart';

enum _HttpMethod { get, post, patch, delete, put, multipart }

abstract class ICpDio {
  Future<dynamic> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 10),
    String? type,
    Map<String, String>? pathParams,
    bool returnDioResponse = false,
  });

  Future<dynamic> get(
    Uri url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
    String? type,
    Map<String, String>? pathParams,
    bool returnDioResponse = false,
  });

  Future<dynamic> patch({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool returnDioResponse = false,
  });

  Future<dynamic> delete({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool returnDioResponse = false,
  });

  Future<dynamic> put({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool returnDioResponse = false,
  });

  Future<dynamic> multiFiles({
    required Uri uri,
    required List<dynamic> fileList,
    List<Map<String, String>>? fields,
    required String type,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool returnDioResponse = false,
  });
}

class CpDio implements ICpDio {
  final Dio _dio;
  final IInternetService _internetService;
  final ITokenService _tokenService;

  CpDio(this._internetService, this._tokenService, [Dio? dio])
    : _dio = dio ?? Dio() {
    final internalDio = Dio();
    _dio.interceptors.add(CustomInterceptors.auth(
      readToken: _tokenService.read,
      saveToken: _tokenService.save,
      readCredentials: _tokenService.readCredentials,
      internalDio: internalDio,
      loginUri: CustomConfigs.uries.login,
      refreshUri: CustomConfigs.uries.refreshToken,
      checkConnectivity: _internetService.isConnected,
    ));
  }

  static Uri _urlParameters(Uri uri, Map<String, String>? pathParams) {
    if (pathParams == null) return uri;
    pathParams.forEach((key, value) {
      uri = uri.replace(path: uri.path.replaceAll(':$key', value));
    });
    return uri;
  }

  Future<dynamic> _request({
    required _HttpMethod method,
    required Uri uri,
    String? type,
    Map<String, String>? headers,
    List<Map<String, String>>? fields,
    List<dynamic>? fileList,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool returnDioResponse = false,
  }) async {
    if (!await _internetService.isConnected()) {
      throw CustomExceptions.noConnection();
    }
    if (!await _internetService.isServerReachable()) {
      throw CustomExceptions.serverUnreachable();
    }
    try {
      Response response;
      final Options requestOptions =
          (type == 'bytes' ||
              (headers != null && headers['Content-Type'] == 'application/pdf'))
          ? Options(headers: headers, responseType: ResponseType.bytes)
          : Options(headers: headers);

      switch (method) {
        case _HttpMethod.get:
          response = await _dio
              .getUri(uri, options: requestOptions)
              .timeout(timeout);
        case _HttpMethod.post:
          response = await _dio
              .postUri(uri, data: body, options: requestOptions)
              .timeout(timeout);
        case _HttpMethod.patch:
          response = await _dio
              .patchUri(uri, data: body, options: requestOptions)
              .timeout(timeout);
        case _HttpMethod.delete:
          response = await _dio
              .deleteUri(uri, data: body, options: requestOptions)
              .timeout(timeout);
        case _HttpMethod.put:
          response = await _dio
              .putUri(uri, data: body, options: requestOptions)
              .timeout(timeout);
        case _HttpMethod.multipart:
          final formData = FormData();
          if (fields != null && fields.isNotEmpty) {
            if (fileList != null && fields.length == fileList.length) {
              for (int i = 0; i < fileList.length; i++) {
                final f = fileList[i];
                final mf =
                    (f as dynamic).multipartFile ??
                    (f is MultipartFile ? f : null);
                if (mf != null) formData.files.add(MapEntry('file', mf));
                fields[i].forEach(
                  (key, value) => formData.fields.add(MapEntry(key, value)),
                );
              }
            } else {
              for (final map in fields) {
                map.forEach(
                  (key, value) => formData.fields.add(MapEntry(key, value)),
                );
              }
              if (fileList != null) {
                for (final f in fileList) {
                  final mf =
                      (f as dynamic).multipartFile ??
                      (f is MultipartFile ? f : null);
                  if (mf != null) formData.files.add(MapEntry('file', mf));
                }
              }
            }
          } else {
            if (fileList != null) {
              for (final f in fileList) {
                final mf =
                    (f as dynamic).multipartFile ??
                    (f is MultipartFile ? f : null);
                if (mf != null) formData.files.add(MapEntry('file', mf));
              }
            }
          }
          response = await _dio
              .postUri(uri, data: formData, options: requestOptions)
              .timeout(timeout);
      }

      if (returnDioResponse) return response;

      if (type == 'bytes' &&
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;
        if (data is List<int>) return List<int>.from(data);
        throw CustomExceptions.unexpectedResponse(
          'Respuesta no es bytes: ${data.runtimeType}',
        );
      }

      if (type == 'image' &&
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return response;
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final respString = response.data is List<int>
            ? utf8.decode(List<int>.from(response.data))
            : response.toString();
        final responseBody = jsonDecode(respString);
        if (responseBody is List) {
          return responseBody.cast<Map<String, dynamic>>();
        }
        return responseBody as Map<String, dynamic>;
      }

      return response;
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      if (e.response != null) {
        throw CustomExceptions.usingApi(status);
      }
      throw CustomExceptions.noConnection();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<dynamic> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    String? type,
    Map<String, String>? pathParams,
    bool returnDioResponse = false,
  }) async {
    url = _urlParameters(url, pathParams);
    return await _request(
      method: _HttpMethod.post,
      uri: url,
      headers: headers,
      body: body,
      timeout: timeout,
      returnDioResponse: returnDioResponse,
    );
  }

  @override
  Future<dynamic> get(
    Uri url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
    String? type,
    Map<String, String>? pathParams,
    bool returnDioResponse = false,
  }) async {
    url = _urlParameters(url, pathParams);
    return await _request(
      method: _HttpMethod.get,
      uri: url,
      type: type,
      headers: headers,
      timeout: timeout,
      returnDioResponse: returnDioResponse,
    );
  }

  @override
  Future<dynamic> patch({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool returnDioResponse = false,
  }) async {
    uri = _urlParameters(uri, pathParams);
    return await _request(
      method: _HttpMethod.patch,
      uri: uri,
      headers: headers,
      body: body,
      timeout: timeout,
      returnDioResponse: returnDioResponse,
    );
  }

  @override
  Future<dynamic> delete({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool returnDioResponse = false,
  }) async {
    uri = _urlParameters(uri, pathParams);
    return await _request(
      method: _HttpMethod.delete,
      uri: uri,
      headers: headers,
      body: body,
      timeout: timeout,
      returnDioResponse: returnDioResponse,
    );
  }

  @override
  Future<dynamic> put({
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool returnDioResponse = false,
  }) async {
    uri = _urlParameters(uri, pathParams);
    return await _request(
      method: _HttpMethod.put,
      uri: uri,
      headers: headers,
      body: body,
      timeout: timeout,
      returnDioResponse: returnDioResponse,
    );
  }

  @override
  Future<dynamic> multiFiles({
    required Uri uri,
    required List<dynamic> fileList,
    List<Map<String, String>>? fields,
    required String type,
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool returnDioResponse = false,
  }) async {
    uri = _urlParameters(uri, pathParams);
    return await _request(
      method: _HttpMethod.multipart,
      type: type,
      uri: uri,
      fileList: fileList,
      headers: headers,
      body: body,
      fields: fields,
      timeout: timeout,
      returnDioResponse: returnDioResponse,
    );
  }
}
