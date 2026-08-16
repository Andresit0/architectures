class DeviceSecurityException implements Exception {
  const DeviceSecurityException([
    this.message = 'Device is jailbroken or rooted',
  ]);
  final String message;

  @override
  String toString() => 'DeviceSecurityException: $message';
}
