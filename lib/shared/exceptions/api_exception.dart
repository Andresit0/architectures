class ApiException implements Exception {
  final int statusCode;

  const ApiException(this.statusCode);

  @override
  String toString() => 'ApiException: HTTP $statusCode';
}
