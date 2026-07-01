part of '_interceptors.lib.dart';

class CustomInterceptors {
  static AuthInterceptor auth(Future<String?> Function() readToken) =>
      AuthInterceptor(readToken);
}
