enum ClinicalHistoryStatus {
  ready,
  pending,
  closed,
  unknown;

  static ClinicalHistoryStatus fromCode(String? code) {
    if (code == null) return ClinicalHistoryStatus.unknown;
    return switch (code.toLowerCase()) {
      'ready' => ClinicalHistoryStatus.ready,
      'pending' => ClinicalHistoryStatus.pending,
      'closed' => ClinicalHistoryStatus.closed,
      _ => ClinicalHistoryStatus.unknown,
    };
  }
}
