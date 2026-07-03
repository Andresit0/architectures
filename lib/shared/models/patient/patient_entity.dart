import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_entity.freezed.dart';
part 'patient_entity.g.dart';

@freezed
abstract class PatientEntity with _$PatientEntity {
  const PatientEntity._();

  const factory PatientEntity({
    required String name,
    required String id,
  }) = _PatientEntity;

  factory PatientEntity.fromJson(Map<String, dynamic> json) =>
      _$PatientEntityFromJson(json);
}
