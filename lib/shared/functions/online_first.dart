import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

enum DataOrigin { remote, cache }

final class OnlineFirstResult<T> {
  const OnlineFirstResult._({required this.result, required this.origin});

  factory OnlineFirstResult.success(T data, DataOrigin origin) =>
      OnlineFirstResult._(result: Success(data), origin: origin);

  factory OnlineFirstResult.failure(AppError error, DataOrigin origin) =>
      OnlineFirstResult._(result: Failure<T>(error), origin: origin);

  final Result<T> result;
  final DataOrigin origin;
}

Future<OnlineFirstResult<T>> fetchOrFallback<T>({
  required Future<T> Function() remote,
  required Future<T?> Function() local,
  Future<void> Function(T data)? onRemoteSuccess,
}) async {
  final remoteResult = await guard(remote);
  if (remoteResult is Success<T>) {
    final data = remoteResult.data;
    if (onRemoteSuccess != null) {
      final cacheWrite = await guard(() => onRemoteSuccess(data));
      if (cacheWrite is Failure<void>) {
        return OnlineFirstResult.failure(cacheWrite.error, DataOrigin.remote);
      }
    }
    return OnlineFirstResult.success(data, DataOrigin.remote);
  }

  final remoteError = (remoteResult as Failure<T>).error;
  if (!remoteError.isNetworkRelated) {
    return OnlineFirstResult.failure(remoteError, DataOrigin.remote);
  }

  final localResult = await guard(local);
  return switch (localResult) {
    Success(data: final localData) =>
      localData != null
          ? OnlineFirstResult.success(localData, DataOrigin.cache)
          : OnlineFirstResult.failure(remoteError, DataOrigin.remote),
    Failure(error: final localError) => OnlineFirstResult.failure(
      localError,
      DataOrigin.cache,
    ),
  };
}
