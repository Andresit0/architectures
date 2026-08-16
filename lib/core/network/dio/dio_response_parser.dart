import 'dart:convert';

import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/http_response.dart';
import 'package:dio/dio.dart';

abstract interface class IDioResponseParser {
  HttpResponse<Map<String, dynamic>> parse({
    required Response<dynamic> response,
    required String? type,
    required bool returnDioResponse,
  });
}

class DioResponseParser implements IDioResponseParser {
  const DioResponseParser();

  @override
  HttpResponse<Map<String, dynamic>> parse({
    required Response<dynamic> response,
    required String? type,
    required bool returnDioResponse,
  }) {
    if (returnDioResponse) {
      return HttpSuccess(statusCode: response.statusCode);
    }

    final statusCode = response.statusCode;

    if (type == 'bytes' && _is2xx(statusCode)) {
      if (response.data is List<int>) {
        return HttpSuccess(statusCode: statusCode);
      }
      throw UnexpectedResponseException(
        'Expected a bytes body, got ${response.data.runtimeType}',
      );
    }

    if (type == 'image' && _is2xx(statusCode)) {
      return HttpSuccess(statusCode: statusCode);
    }

    if (!_is2xx(statusCode)) {
      throw UnexpectedResponseException(
        'Non-2xx status $statusCode must be handled before parsing',
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return HttpSuccess(data: data, statusCode: statusCode);
    }
    if (data is List<int>) {
      final decoded = jsonDecode(utf8.decode(data));
      if (decoded is Map<String, dynamic>) {
        return HttpSuccess(data: decoded, statusCode: statusCode);
      }
      return HttpSuccess(statusCode: statusCode);
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return HttpSuccess(data: decoded, statusCode: statusCode);
      }
      return HttpSuccess(statusCode: statusCode);
    }
    if (data is List) {
      return HttpSuccess(statusCode: statusCode);
    }

    throw UnexpectedResponseException(
      'Unexpected body type: ${data.runtimeType}',
    );
  }

  bool _is2xx(int? statusCode) =>
      statusCode != null && statusCode >= 200 && statusCode < 300;
}
