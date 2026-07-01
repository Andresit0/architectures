part of '_exceptions.lib.dart';

class UnexpectedFailure extends Failure {
  const UnexpectedFailure()
    : super(
        'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo más tarde.',
      );
}
