import 'lab_result_dto.dart';

class LabResultsListResponseDto {
  const LabResultsListResponseDto({required this.labResults});

  factory LabResultsListResponseDto.fromJson(Map<String, dynamic> json) =>
      LabResultsListResponseDto(
        labResults: (json['lab_results'] as List<dynamic>)
            .map((e) => LabResultDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final List<LabResultDto> labResults;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'lab_results': labResults.map((e) => e.toJson()).toList(),
  };
}
