part of '_exceptions.lib.dart';

class CustomExceptions {
  static ApiException usingApi(int statusCode) => ApiException(statusCode);

  static NoConnectionException noConnection() => const NoConnectionException();

  static ServerUnreachableException serverUnreachable() =>
      const ServerUnreachableException();

  static UnexpectedResponseException unexpectedResponse(String details) =>
      UnexpectedResponseException(details);
}
