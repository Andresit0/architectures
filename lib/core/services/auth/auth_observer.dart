import 'package:clean_architecture_sdd_harness/shared/interfaces/i_authentication_observer.dart';
import 'package:flutter/foundation.dart';

/// Observes authentication state and notifies listeners.
/// Used by [authenticationObserverProvider] and [GoRouter] for redirect guards.
class AuthObserver extends ChangeNotifier implements IAuthenticationObserver {
  bool _isAuthenticated = false;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  void update(bool value) {
    if (value != _isAuthenticated) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }
}
