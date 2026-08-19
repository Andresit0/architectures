import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:clean_architecture_sdd_harness/core/network/contracts/_contracts.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/dtos/_dtos.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/mappers/auth_mapper.dart';

void main() {
  group('AuthMapper', () {
    group('loginResponseFromDto', () {
      test('mapea todos los campos', () {
        final dto = LoginResponseDto(
          patient: PatientDto(id: '1', name: 'John'),
          token: TokenDto(key: 'token'),
          clinicalHistory: [],
        );
        final entity = AuthMapper.loginResponseFromDto(dto);
        expect(entity.patient.id, '1');
        expect(entity.patient.name, 'John');
        expect(entity.token.key, 'token');
        expect(entity.clinicalHistory, isEmpty);
      });
    });

    group('tokenFromDto', () {
      test('mapea correctamente', () {
        final dto = TokenDto(key: 'jwt');
        final entity = AuthMapper.tokenFromDto(dto);
        expect(entity.key, 'jwt');
      });
    });

    group('patientFromDto', () {
      test('mapea correctamente', () {
        final dto = PatientDto(id: 'p1', name: 'John Doe');
        final entity = AuthMapper.patientFromDto(dto);
        expect(entity.id, 'p1');
        expect(entity.name, 'John Doe');
      });
    });

    group('VGV compliance', () {
      test('NO usa Entity.fromJson en ninguna parte', () {
        final sourceFile = File(
          'lib/features/auth/infrastructure/mappers/auth_mapper.dart',
        );
        final source = sourceFile.readAsStringSync();
        expect(
          source.contains('.fromJson'),
          isFalse,
          reason: 'El mapper no debe contener ninguna llamada a .fromJson',
        );
      });
    });
  });
}
