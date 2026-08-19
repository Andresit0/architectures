sealed class AppError {
  const AppError({this.technicalMessage, this.stackTrace});

  final String? technicalMessage;
  final StackTrace? stackTrace;

  bool get isNetworkRelated => false;

  bool get isTransient => false;

  @override
  String toString() => '$runtimeType(technicalMessage: $technicalMessage)';
}

final class ApiError extends AppError {
  const ApiError({super.technicalMessage, super.stackTrace});
}

final class NetworkError extends AppError {
  const NetworkError({super.technicalMessage, super.stackTrace});

  @override
  bool get isNetworkRelated => true;

  @override
  bool get isTransient => true;
}

final class ServerUnreachableError extends AppError {
  const ServerUnreachableError({super.technicalMessage, super.stackTrace});

  @override
  bool get isNetworkRelated => true;

  @override
  bool get isTransient => true;
}

final class TimeoutError extends AppError {
  const TimeoutError({super.technicalMessage, super.stackTrace});

  @override
  bool get isTransient => true;
}

final class UnexpectedError extends AppError {
  const UnexpectedError({super.technicalMessage, super.stackTrace});
}

final class DeviceSecurityError extends AppError {
  const DeviceSecurityError({super.technicalMessage, super.stackTrace});
}

final class ValidationError extends AppError {
  const ValidationError({super.technicalMessage, super.stackTrace, this.field});
  final String? field;
}
