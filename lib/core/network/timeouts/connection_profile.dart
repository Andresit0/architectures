class ConnectionProfile {
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const ConnectionProfile._({
    required this.connectTimeout,
    required this.receiveTimeout,
    this.sendTimeout = const Duration(seconds: 10),
  });

  static const standard = ConnectionProfile._(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 15),
    sendTimeout: Duration(seconds: 10),
  );
}
