part of '_exceptions.lib.dart';

class ApiFailure extends Failure {
  const ApiFailure()
    : super(
        'La solicitud tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.',
      );
}
