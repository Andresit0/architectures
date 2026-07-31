abstract interface class IAuthenticationObserver {
  bool get isAuthenticated;
  void update(bool value);
}
