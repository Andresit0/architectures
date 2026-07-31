import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_service_entity.freezed.dart';

@freezed
abstract class ClinicalHistoryServiceEntity with _$ClinicalHistoryServiceEntity {
  const ClinicalHistoryServiceEntity._();

  const factory ClinicalHistoryServiceEntity({
    required String code,
    required String name,
    required String category,
  }) = _ClinicalHistoryServiceEntity;
}
