part of '_exceptions.lib.dart';

class UnexpectedResponseFailure extends Failure {
  const UnexpectedResponseFailure()
    : super(
        'Unexpected server response. Please try again later.',
      );
}
