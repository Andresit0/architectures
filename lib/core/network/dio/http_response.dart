class HttpResponse<T> {
  const HttpResponse({this.data, this.statusCode});
  final T? data;
  final int? statusCode;
}

class HttpSuccess<T> extends HttpResponse<T> {
  const HttpSuccess({super.data, super.statusCode});
}
