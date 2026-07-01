part of '_exceptions.lib.dart';

class UnexpectedResponseFailure extends Failure {
  const UnexpectedResponseFailure()
    : super(
        'La respuesta del servidor no es la esperada. Por favor, inténtalo de nuevo más tarde.',
      );
}
