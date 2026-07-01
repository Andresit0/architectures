import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

class TestFailure extends Failure {
  const TestFailure(super.message);
}

void main() {
  group('Failures', () {
    test('Failure should have correct message', () {
      const failure = TestFailure('test message');
      expect(failure.message, 'test message');
    });

    test('ApiFailure should have default message', () {
      const failure = ApiFailure();
      expect(failure.message, 'La solicitud tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.');
    });

    test('NoConnectionFailure should have correct message', () {
      const failure = NoConnectionFailure();
      expect(failure.message, 'Sin conexión a internet');
    });

    test('ServerUnreachableFailure should have correct message', () {
      const failure = ServerUnreachableFailure();
      expect(failure.message, 'Estamos en mantenimiento');
    });

    test('UnexpectedFailure should have default message', () {
      const failure = UnexpectedFailure();
      expect(failure.message, 'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo más tarde.');
    });

    test('UnexpectedResponseFailure should have correct message', () {
      const failure = UnexpectedResponseFailure();
      expect(failure.message, 'La respuesta del servidor no es la esperada. Por favor, inténtalo de nuevo más tarde.');
    });

    test('NoRequestFailure should have correct message', () {
      const failure = NoRequestFailure();
      expect(failure.message, 'Esta función no se ha implementado aún. Esperamos tenerla disponible pronto.');
    });
  });

  group('Exceptions', () {
    test('ApiException should have correct toString', () {
      const exception = ApiException(404);
      expect(exception.toString(), contains('404'));
      expect(exception.toString(), contains('La solicitud tardó demasiado'));
    });

    test('ApiException should have correct statusCode', () {
      const exception = ApiException(500);
      expect(exception.statusCode, 500);
    });

    test('NoConnectionException should have toString', () {
      const exception = NoConnectionException();
      expect(exception.toString(), isNotEmpty);
    });

    test('ServerUnreachableException should have toString', () {
      const exception = ServerUnreachableException();
      expect(exception.toString(), isNotEmpty);
    });

    test('UnexpectedResponseException should require details parameter', () {
      const exception = UnexpectedResponseException('test details');
      expect(exception.details, 'test details');
    });

    test('NoRequestException should require method parameter', () {
      const exception = NoRequestException('GET');
      expect(exception.method, 'GET');
    });
  });
}