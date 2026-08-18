class LabResultReferenceRangeDto {
  const LabResultReferenceRangeDto({required this.low, required this.high});

  factory LabResultReferenceRangeDto.fromJson(Map<String, dynamic> json) =>
      LabResultReferenceRangeDto(
        low: (json['low'] as num).toDouble(),
        high: (json['high'] as num).toDouble(),
      );

  final double low;
  final double high;

  Map<String, dynamic> toJson() => <String, dynamic>{'low': low, 'high': high};
}
