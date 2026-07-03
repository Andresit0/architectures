part of '_function.lib.dart';

abstract class IFailurePropagation {
  T launch<T>(Failure failure, {required T Function(String message) onFailure});
}

class FailurePropagation implements IFailurePropagation {
  @override
  T launch<T>(
    Failure failure, {
    required T Function(String message) onFailure,
  }) {
    return switch (failure) {
      ApiFailure() => onFailure(failure.message),
      NoConnectionFailure() => onFailure(failure.message),
      ServerUnreachableFailure() => onFailure(failure.message),
      UnexpectedResponseFailure() => onFailure(failure.message),
      UnexpectedFailure() => onFailure(failure.message),
      _ => onFailure(failure.message),
    };
  }
}
