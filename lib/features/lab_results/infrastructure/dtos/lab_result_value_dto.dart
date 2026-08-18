class LabResultValueDto {
  const LabResultValueDto({required this.date, this.value});

  factory LabResultValueDto.fromJson(Map<String, dynamic> json) =>
      LabResultValueDto(
        date: DateTime.parse(json['date'] as String),
        value: json['value'],
      );

  final DateTime date;
  final dynamic value;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': date.toIso8601String(),
    'value': value,
  };
}
