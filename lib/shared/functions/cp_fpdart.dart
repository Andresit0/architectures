part of '_function.lib.dart';

abstract class ICpFpdart {
  Future<Either<Failure, T>> guard<T>(Future<T> Function() call);
}

class CpFpdart implements ICpFpdart {
  Either<Failure, T> _leftFrom<E, T>(
    E e,
    StackTrace st,
    Failure Function(E) build,
  ) {
    CustomFunction.logger.error(e.toString(), st);
    return Left(build(e));
  }

  @override
  Future<Either<Failure, T>> guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ApiException catch (e, st) {
      return _leftFrom(e, st, (_) => const ApiFailure());
    } on NoConnectionException catch (e, st) {
      return _leftFrom(e, st, (_) => const NoConnectionFailure());
    } on ServerUnreachableException catch (e, st) {
      return _leftFrom(e, st, (_) => const ServerUnreachableFailure());
    } on NoRequestException catch (e, st) {
      return _leftFrom(e, st, (_) => const NoRequestFailure());
    } on UnexpectedResponseException catch (e, st) {
      return _leftFrom(e, st, (_) => const UnexpectedResponseFailure());
    } on GoRouterException catch (e, st) {
      return _leftFrom(e, st, (ex) => GoRouterFailure());
    } catch (e, st) {
      return _leftFrom(e, st, (_) => const UnexpectedFailure());
    }
  }
}
