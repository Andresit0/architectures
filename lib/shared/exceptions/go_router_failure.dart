part of '_exceptions.lib.dart';

class GoRouterFailure extends Failure {
  const GoRouterFailure()
    : super(
        'Espera una nueva actualización de la app, para ir a la página solicitada',
      );
}
