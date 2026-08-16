import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_dto.freezed.dart';
part 'patient_dto.g.dart';

@freezed
abstract class PatientDto with _$PatientDto {
  const factory PatientDto({required String id, required String name}) =
      _PatientDto;

  factory PatientDto.fromJson(Map<String, dynamic> json) =>
      _$PatientDtoFromJson(json);
}
