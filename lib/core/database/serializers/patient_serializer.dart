import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

class PatientSerializer {
  static Map<String, dynamic> toMap(PatientEntity entity) => {
    'id': entity.id,
    'name': entity.name,
  };

  static PatientEntity fromMap(Map<String, dynamic> map) =>
      PatientEntity(id: map['id'] as String, name: map['name'] as String);
}
