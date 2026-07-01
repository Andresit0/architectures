part of '_function.lib.dart';

abstract class IInternetService {
  Future<bool> isConnected();
  Future<bool> isServerReachable();
}

class InternetService implements IInternetService {
  DateTime? _lastReachableCheck;
  bool? _lastReachableResult;
  static const _cacheDuration = Duration(seconds: 10);

  @override
  Future<bool> isConnected() => InternetConnection().hasInternetAccess;

  @override
  Future<bool> isServerReachable() async {
    final now = DateTime.now();
    if (_lastReachableCheck != null &&
        _lastReachableResult != null &&
        now.difference(_lastReachableCheck!) < _cacheDuration) {
      return _lastReachableResult!;
    }
    try {
      final socket = await Socket.connect(
        CustomConfigs.uries.host,
        CustomConfigs.uries.port,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      _lastReachableCheck = now;
      _lastReachableResult = true;
      return true;
    } catch (_) {
      _lastReachableCheck = now;
      _lastReachableResult = false;
      return false;
    }
  }
}
