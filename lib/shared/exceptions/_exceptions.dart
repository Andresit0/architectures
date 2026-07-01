part of '_exceptions.lib.dart';

class CustomExceptions {
  static ApiException usingApi(int statusCode) => ApiException(statusCode);

  static GoRouterException goRouter(String message) =>
      GoRouterException(message);

  static NoConnectionException noConnection() => const NoConnectionException();

  static NoRequestException noRequest(String method) =>
      NoRequestException(method);

  static ServerUnreachableException serverUnreachable() =>
      const ServerUnreachableException();

  static UnexpectedResponseException unexpectedResponse(String details) =>
      UnexpectedResponseException(details);
}
