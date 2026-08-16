import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

Future<Result<T>> fetchOrFallback<T>({
  required Future<Result<T>> Function() remote,
  required Future<Result<T?>> Function() local,
}) async {
  final r = await remote();
  if (r.isSuccess) return r;

  final error = r.fold(onSuccess: (_) => null, onFailure: (e) => e);

  if (error != null && error.isNetworkRelated) {
    final l = await local();
    final localData = l.fold(onSuccess: (data) => data, onFailure: (_) => null);
    if (localData != null) return Success<T>(localData);
  }

  return r;
}
