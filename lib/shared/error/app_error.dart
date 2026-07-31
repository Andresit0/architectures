sealed class AppError {
  const AppError(this.userMessage, {this.technicalMessage, this.stackTrace});

  const AppError.technical({this.technicalMessage, this.stackTrace}) : userMessage = '';

  final String userMessage;
  final String? technicalMessage;
  final StackTrace? stackTrace;

  bool get isNetworkRelated => false;
}

final class ApiError extends AppError {
  const ApiError(super.userMessage, {this.statusCode, super.technicalMessage, super.stackTrace});
  const ApiError.technical({super.technicalMessage, super.stackTrace, this.statusCode}) : super.technical();
  final int? statusCode;
}

final class NetworkError extends AppError {
  const NetworkError(super.userMessage, {super.technicalMessage, super.stackTrace});
  const NetworkError.technical({super.technicalMessage, super.stackTrace}) : super.technical();

  @override
  bool get isNetworkRelated => true;
}

final class ServerUnreachableError extends AppError {
  const ServerUnreachableError(super.userMessage, {super.technicalMessage, super.stackTrace});
  const ServerUnreachableError.technical({super.technicalMessage, super.stackTrace}) : super.technical();

  @override
  bool get isNetworkRelated => true;
}

final class UnexpectedError extends AppError {
  const UnexpectedError(super.userMessage, {super.technicalMessage, super.stackTrace});
  const UnexpectedError.technical({super.technicalMessage, super.stackTrace}) : super.technical();
}

final class DeviceSecurityError extends AppError {
  const DeviceSecurityError(super.userMessage, {super.technicalMessage, super.stackTrace});
  const DeviceSecurityError.technical({super.technicalMessage, super.stackTrace}) : super.technical();
}

final class ValidationError extends AppError {
  const ValidationError(super.userMessage, {this.field, super.technicalMessage, super.stackTrace});
  const ValidationError.technical({super.technicalMessage, super.stackTrace, this.field}) : super.technical();
  final String? field;
}
