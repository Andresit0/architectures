import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

void main() {
  group('CpFpdart', () {
    late CpFpdart cpFpdart;

    setUp(() {
      cpFpdart = CpFpdart();
    });

    group('guard', () {
      test('should return Right when function succeeds', () async {
        final result = await cpFpdart.guard(() async => 'success');

        expect(result.isRight(), isTrue);
      });

      test('should return Left with ApiFailure on ApiException', () async {
        final result = await cpFpdart.guard(() async {
          throw ApiException(500);
        });

        expect(result.isLeft(), isTrue);
        result.fold(
          (fail) => expect(fail, isA<ApiFailure>()),
          (_) => fail('should be Left'),
        );
      });

      test(
        'should return Left with NoConnectionFailure on NoConnectionException',
        () async {
          final result = await cpFpdart.guard(() async {
            throw NoConnectionException();
          });

          expect(result.isLeft(), isTrue);
          result.fold(
            (fail) => expect(fail, isA<NoConnectionFailure>()),
            (_) => fail('should be Left'),
          );
        },
      );

      test(
        'should return Left with ServerUnreachableFailure on ServerUnreachableException',
        () async {
          final result = await cpFpdart.guard(() async {
            throw ServerUnreachableException();
          });

          expect(result.isLeft(), isTrue);
          result.fold(
            (fail) => expect(fail, isA<ServerUnreachableFailure>()),
            (_) => fail('should be Left'),
          );
        },
      );

      test(
        'should return Left with NoRequestFailure on NoRequestException',
        () async {
          final result = await cpFpdart.guard(() async {
            throw NoRequestException('GET');
          });

          expect(result.isLeft(), isTrue);
          result.fold(
            (fail) => expect(fail, isA<NoRequestFailure>()),
            (_) => fail('should be Left'),
          );
        },
      );

      test(
        'should return Left with UnexpectedResponseFailure on UnexpectedResponseException',
        () async {
          final result = await cpFpdart.guard(() async {
            throw const UnexpectedResponseException('details');
          });

          expect(result.isLeft(), isTrue);
          result.fold(
            (fail) => expect(fail, isA<UnexpectedResponseFailure>()),
            (_) => fail('should be Left'),
          );
        },
      );

      test(
        'should return Left with GoRouterFailure on GoRouterException',
        () async {
          final result = await cpFpdart.guard(() async {
            throw CustomExceptions.goRouter('go_router error');
          });

          expect(result.isLeft(), isTrue);
          result.fold(
            (fail) => expect(fail, isA<GoRouterFailure>()),
            (_) => fail('should be Left'),
          );
        },
      );

      test(
        'should return Left with UnexpectedFailure on generic exception',
        () async {
          final result = await cpFpdart.guard(() async {
            throw Exception('generic error');
          });

          expect(result.isLeft(), isTrue);
          result.fold(
            (fail) => expect(fail, isA<UnexpectedFailure>()),
            (_) => fail('should be Left'),
          );
        },
      );
    });
  });
}
