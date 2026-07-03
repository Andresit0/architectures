part of '_interceptors.lib.dart';

class CustomInterceptors {
  static AuthInterceptor auth({
    required Future<String?> Function() readToken,
    required Future<void> Function(String) saveToken,
    required Future<({String email, String passwordHash})?> Function()
    readCredentials,
    required Dio internalDio,
    required Uri loginUri,
    required Uri refreshUri,
    required Future<bool> Function() checkConnectivity,
  }) =>
      AuthInterceptor(
        readToken: readToken,
        saveToken: saveToken,
        readCredentials: readCredentials,
        internalDio: internalDio,
        loginUri: loginUri,
        refreshUri: refreshUri,
        checkConnectivity: checkConnectivity,
      );
}