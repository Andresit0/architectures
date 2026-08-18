import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import '../dtos/_dtos.lib.dart';

class LabResultsMapper {
  static List<LabResultEntity> fromDtoList(List<LabResultDto> list) =>
      list.map(fromDto).toList();

  static LabResultEntity fromDto(LabResultDto dto) {
    final kind = LabResultKind.fromCode(dto.kind);
    return LabResultEntity(
      id: dto.id,
      testCode: dto.testCode,
      testName: dto.testName,
      category: dto.category,
      unit: dto.unit,
      kind: kind,
      referenceRange: dto.referenceRange == null
          ? null
          : LabResultReferenceRangeEntity(
              low: dto.referenceRange!.low,
              high: dto.referenceRange!.high,
            ),
      values: dto.values
          .map((v) => _valueFromDto(v, kind))
          .toList(growable: false),
    );
  }

  static LabResultValueEntity _valueFromDto(
    LabResultValueDto dto,
    LabResultKind kind,
  ) {
    final raw = dto.value;
    return switch (kind) {
      LabResultKind.numeric => LabResultValueEntity(
        date: dto.date,
        value: raw is num ? raw.toDouble() : null,
        textValue: null,
      ),
      LabResultKind.text => LabResultValueEntity(
        date: dto.date,
        value: null,
        textValue: raw is String ? raw : null,
      ),
    };
  }
}
