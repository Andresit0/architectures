import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_state_entity.freezed.dart';
part 'clinical_history_state_entity.g.dart';

@freezed
abstract class ClinicalHistoryStateEntity with _$ClinicalHistoryStateEntity {
  const ClinicalHistoryStateEntity._();

  const factory ClinicalHistoryStateEntity({
    required String code,
    required String label,
  }) = _ClinicalHistoryStateEntity;

  factory ClinicalHistoryStateEntity.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryStateEntityFromJson(json);
}
