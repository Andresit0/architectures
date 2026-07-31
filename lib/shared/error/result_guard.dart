import 'dart:async' show TimeoutException;

import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'app_error.dart';
import 'result.dart';

Future<Result<T>> guard<T>(
  Future<T> Function() fn,
) async {
  try {
    final data = await fn();
    return Success(data);
  } on ApiException catch (e, stackTrace) {
    return Failure(ApiError.technical(statusCode: e.statusCode, stackTrace: stackTrace));
  } on NoConnectionException catch (_, stackTrace) {
    return Failure(NetworkError.technical(stackTrace: stackTrace));
  } on ServerUnreachableException catch (_, stackTrace) {
    return Failure(ServerUnreachableError.technical(stackTrace: stackTrace));
  } on UnexpectedResponseException catch (e, stackTrace) {
    return Failure(UnexpectedError.technical(technicalMessage: e.details, stackTrace: stackTrace));
  } on DeviceSecurityException catch (e, stackTrace) {
    return Failure(DeviceSecurityError(e.message, stackTrace: stackTrace));
  } on AppTimeoutException catch (_, stackTrace) {
    return Failure(NetworkError.technical(stackTrace: stackTrace));
  } on TimeoutException catch (_, stackTrace) {
    return Failure(NetworkError.technical(stackTrace: stackTrace));
  } on Error catch (e, stackTrace) {
    return Failure(UnexpectedError.technical(technicalMessage: '$e', stackTrace: stackTrace));
  } on Exception catch (e, stackTrace) {
    return Failure(UnexpectedError.technical(technicalMessage: '$e', stackTrace: stackTrace));
  }
}
