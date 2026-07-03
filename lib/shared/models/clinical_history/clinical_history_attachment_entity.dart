import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_attachment_entity.freezed.dart';
part 'clinical_history_attachment_entity.g.dart';

@freezed
abstract class ClinicalHistoryAttachmentEntity
    with _$ClinicalHistoryAttachmentEntity {
  const ClinicalHistoryAttachmentEntity._();

  const factory ClinicalHistoryAttachmentEntity({
    required String id,
    required String type,
    required String name,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    required String url,
  }) = _ClinicalHistoryAttachmentEntity;

  factory ClinicalHistoryAttachmentEntity.fromJson(
          Map<String, dynamic> json) =>
      _$ClinicalHistoryAttachmentEntityFromJson(json);
}
