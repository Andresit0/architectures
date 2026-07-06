part of '_exceptions.lib.dart';

class UnexpectedFailure extends Failure {
  const UnexpectedFailure()
    : super(
        'An unexpected error occurred. Please try again later.',
      );
}
