abstract interface class IInternetConnectionCheckerWrapper {
  Future<bool> checkConnectivity();
  Stream<bool> get onStatusChange;
}
