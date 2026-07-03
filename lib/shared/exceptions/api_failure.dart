part of '_exceptions.lib.dart';

class ApiFailure extends Failure {
  const ApiFailure()
    : super(
        'The server returned an error. Please try again later.',
      );
}
