import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_history_attachment_dto.freezed.dart';
part 'clinical_history_attachment_dto.g.dart';

@freezed
abstract class ClinicalHistoryAttachmentDto
    with _$ClinicalHistoryAttachmentDto {
  const factory ClinicalHistoryAttachmentDto({
    required String id,
    required String type,
    required String name,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    required String url,
  }) = _ClinicalHistoryAttachmentDto;

  factory ClinicalHistoryAttachmentDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicalHistoryAttachmentDtoFromJson(json);
}
