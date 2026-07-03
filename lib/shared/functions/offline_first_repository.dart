part of '_function.lib.dart';

Future<Either<Failure, T>> fetchOrFallback<T>({
  required Future<Either<Failure, T>> Function() remote,
  required Future<Either<Failure, T?>> Function() local,
}) async {
  final r = await remote();
  if (r.isRight()) return r;
  final failure = r.getLeft().toNullable();
  if (failure is NoConnectionFailure || failure is ServerUnreachableFailure) {
    final l = await local();
    if (l.isRight()) {
      final localData = l.getRight().toNullable();
      if (localData != null) return Right(localData);
    }
  }
  return r;
}
