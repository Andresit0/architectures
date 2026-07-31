import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';

const mockPatient = PatientEntity(id: '1', name: 'John Doe');

const mockToken = TokenEntity(
  type: 'Bearer',
  key: 'jwt_token_123',
);

const mockLoginResponse = LoginResponseEntity(
  patient: mockPatient,
  token: mockToken,
  clinicalHistory: [],
);

const fallbackPatient = PatientEntity(id: '', name: '');

const fallbackToken = TokenEntity(
  type: '',
  key: '',
);

const fallbackLoginResponse = LoginResponseEntity(
  patient: fallbackPatient,
  token: fallbackToken,
  clinicalHistory: [],
);
