import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_attachment_entity.freezed.dart';

@freezed
abstract class ClinicalHistoryAttachmentEntity
    with _$ClinicalHistoryAttachmentEntity {
  const ClinicalHistoryAttachmentEntity._();

  const factory ClinicalHistoryAttachmentEntity({
    required String id,
    required String type,
    required String name,
    required int sizeBytes,
    required String url,
  }) = _ClinicalHistoryAttachmentEntity;
}
