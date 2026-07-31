class ServerUnreachableException implements Exception {
  const ServerUnreachableException();

  @override
  String toString() => 'ServerUnreachableException: Server not available';
}
