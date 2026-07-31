import 'package:clean_architecture_sdd_harness/shared/interfaces/i_connectivity_checker.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/i_internet_connection_checker_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/internet_connection_checker_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/server_reachability_strategy.dart';

abstract interface class IInternetService implements IConnectivityChecker {
  Future<bool> isServerReachable();
}

class InternetService implements IInternetService {

  InternetService({
    required this._strategy,
    IInternetConnectionCheckerWrapper? connectionChecker,
  }) : _connectionChecker = connectionChecker ?? const InternetConnectionCheckerWrapper();
  final IServerReachabilityStrategy _strategy;
  final IInternetConnectionCheckerWrapper _connectionChecker;
  DateTime? _lastReachableCheck;
  bool? _lastReachableResult;
  static const _cacheDuration = Duration(seconds: 10);

  @override
  Future<bool> isConnected() => _connectionChecker.checkConnectivity();

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
