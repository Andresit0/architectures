import 'package:clean_architecture_sdd_harness/core/network/contracts/clinical_history_mapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/contracts/patient_dto.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/infrastructure/dtos/_dtos.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class AuthMapper {
  static LoginResponseEntity loginResponseFromDto(LoginResponseDto dto) =>
      LoginResponseEntity(
        patient: patientFromDto(dto.patient),
        token: tokenFromDto(dto.token),
        clinicalHistory: ClinicalHistoryMapper.fromDtoList(dto.clinicalHistory),
      );

  static TokenEntity tokenFromDto(TokenDto dto) => TokenEntity(key: dto.key);

  static PatientEntity patientFromDto(PatientDto dto) =>
      PatientEntity(id: dto.id, name: dto.name);
}
