import 'dart:convert';

import 'package:clean_architecture_sdd_harness/shared/exceptions/unexpected_response_exception.dart';
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

    if (type == 'bytes' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (data is List<int>) {
        return HttpSuccess(statusCode: response.statusCode);
      }
      throw UnexpectedResponseException(
        'Respuesta no es bytes: ${data.runtimeType}',
      );
    }

    if (type == 'image' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return HttpSuccess(statusCode: response.statusCode);
    }

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final respString = response.data is List<int>
          ? utf8.decode(response.data as List<int>)
          : response.toString();
      final responseBody = jsonDecode(respString);
      if (responseBody is List) {
        return HttpSuccess(statusCode: response.statusCode);
      }
      return HttpSuccess(
        data: responseBody as Map<String, dynamic>,
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode != null && response.statusCode! >= 400) {
      final rawData = response.data;
      final mapData = rawData is Map<String, dynamic> ? rawData : null;
      return HttpFailure(
        statusCode: response.statusCode!,
        data: mapData,
        message: mapData?['message'] as String?,
      );
    }

    return HttpSuccess(statusCode: response.statusCode);
  }
}
