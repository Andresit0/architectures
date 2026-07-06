part of '_jsons.lib.dart';

class AuthJson {
  final Map<String, dynamic> patientInfo = {
    "id": "PT-98765",
    "name": "John Doe",
  };

  final Map<String, dynamic> loginResponse200 = {
    "patient": {
      "name": "John Doe",
      "id": "PT-98765"
    },
    "token": {
      "type": "Bearer",
      "key": "eyJ...",
      "expires_in_hours": 2,
      "expiration_date": "2026-06-24T21:13:43Z"
    },
    "clinical_history": [
      {
        "id": "history_001",
        "encounter_number": "ENC-20260624-0001",
        "service": {"code": "GEN", "name": "General Medicine", "category": "consultation"},
        "facility": {"id": "FAC-001", "name": "Central Medical Center", "city": "Quito"},
        "professional": {"id": "DOC-1001", "fullname": "Dr. Sarah Johnson", "specialty": "Internal Medicine"},
        "encounter_date": "2026-06-24",
        "created_at": "2026-06-24T08:30:00Z",
        "updated_at": "2026-06-24T09:20:00Z",
        "published_at": "2026-06-24T10:15:00Z",
        "summary": "Routine annual checkup.",
        "description": "Results show normal cholesterol levels and excellent overall health.",
        "diagnosis": [{"code": "Z00.00", "name": "General adult medical examination"}],
        "observations": ["Blood pressure normal", "No signs of cardiovascular disease"],
        "attachments": [{"id": "FILE-001", "type": "pdf", "name": "medical-report.pdf", "size_bytes": 248530, "url": "https://example.com/report-001.pdf"}],
        "state": {"code": "ready", "label": "Available"}
      },
      {
        "id": "history_002",
        "encounter_number": "ENC-20260628-0002",
        "service": {"code": "LAB", "name": "Laboratory", "category": "exam"},
        "facility": {"id": "FAC-001", "name": "Central Medical Center", "city": "Quito"},
        "professional": null,
        "encounter_date": "2026-06-28",
        "created_at": "2026-06-28T13:00:00Z",
        "updated_at": "2026-06-28T13:00:00Z",
        "published_at": null,
        "summary": "Blood analysis requested.",
        "description": null,
        "diagnosis": [],
        "observations": [],
        "attachments": [],
        "state": {"code": "pending", "label": "Processing"}
      }
    ]
  };
}
