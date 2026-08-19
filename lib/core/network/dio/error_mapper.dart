import 'package:dio/dio.dart';

abstract interface class IErrorMapper {
  bool isBrowserNetworkFailure(DioException e);
}

class ErrorMapper implements IErrorMapper {
  const ErrorMapper();

  @override
  bool isBrowserNetworkFailure(DioException e) {
    if (e.type != DioExceptionType.unknown) {
      return false;
    }
    final error = e.error;
    final message = error?.toString() ?? '';
    return error is TypeError ||
        message.contains('Failed to fetch') ||
        message.contains('Network Error');
  }
}
