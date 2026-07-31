class ApiException implements Exception {
  final int statusCode;

  const ApiException(this.statusCode);

  @override
  String toString() =>
      'ApiException($statusCode): The server returned an error. Please try again later.';
}
