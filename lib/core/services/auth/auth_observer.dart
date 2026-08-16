import 'package:clean_architecture_sdd_harness/core/services/auth/i_authentication_observer.dart';
import 'package:flutter/foundation.dart';

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
