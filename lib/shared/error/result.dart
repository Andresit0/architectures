import 'app_error.dart';

sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  });

  bool get isSuccess;
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onSuccess(data);

  @override
  bool get isSuccess => true;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppError error;

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onFailure(error);

  @override
  bool get isSuccess => false;
}
