import 'package:flutter/foundation.dart' show Listenable;

abstract interface class IAuthenticationObserver implements Listenable {
  bool get isAuthenticated;
  void update(bool value);
}
