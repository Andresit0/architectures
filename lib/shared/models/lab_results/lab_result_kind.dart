enum LabResultKind {
  numeric,
  text;

  static LabResultKind fromCode(String? code) {
    if (code == null) return LabResultKind.text;
    return switch (code.toLowerCase()) {
      'numeric' => LabResultKind.numeric,
      _ => LabResultKind.text,
    };
  }
}
