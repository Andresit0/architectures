part of '_function.lib.dart';

abstract class IInternetService {
  Future<bool> isConnected();
  Future<bool> isServerReachable();
}

class InternetService implements IInternetService {
  final IServerReachabilityStrategy _strategy;
  DateTime? _lastReachableCheck;
  bool? _lastReachableResult;
  static const _cacheDuration = Duration(seconds: 10);

  InternetService({required this._strategy});

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
      final result = await _strategy.check();
      _lastReachableCheck = now;
      _lastReachableResult = result;
      return result;
    } catch (_) {
      _lastReachableCheck = now;
      _lastReachableResult = false;
      return false;
    }
  }
}
