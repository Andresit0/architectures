import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoRouterListenable extends ChangeNotifier {
  bool _isAuthenticated;

  GoRouterListenable(bool initialValue) : _isAuthenticated = initialValue;

  bool get isAuthenticated => _isAuthenticated;

  void update(bool value) {
    if (_isAuthenticated == value) return;
    _isAuthenticated = value;
    notifyListeners();
  }
}

final goRouterListenableProvider = Provider<GoRouterListenable>((ref) {
  return GoRouterListenable(false);
});
