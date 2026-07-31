class HttpResponse<T> {
  const HttpResponse({this.data, this.statusCode});
  final T? data;
  final int? statusCode;
}

class HttpSuccess<T> extends HttpResponse<T> {
  const HttpSuccess({super.data, super.statusCode});
}

class HttpFailure extends HttpResponse<Map<String, dynamic>> {
  final String? message;
  const HttpFailure({required super.statusCode, super.data, this.message});
}
