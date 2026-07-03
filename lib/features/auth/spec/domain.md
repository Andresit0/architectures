models:
  - name: PatientEntity
    layer: domain
    file: shared/models/patient/patient_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      name:
        type: String
        json_key: name
        required: true
      id:
        type: String
        json_key: id
        required: true
    notes:
      - Represents the authenticated patient.

  - name: TokenEntity
    layer: domain
    file: features/auth/domain/entities/token_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      type:
        type: String
        json_key: type
        required: true
      key:
        type: String
        json_key: key
        required: true
      expiresInHours:
        type: int
        json_key: expires_in_hours
        required: true
      expirationDate:
        type: DateTime?
        json_key: expiration_date
        required: true
    notes:
      - Contains the JWT token and its metadata.

  - name: LoginResponseEntity
    layer: domain
    file: features/auth/domain/entities/login_response_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      patient:
        type: PatientEntity
        json_key: patient
        required: true
      token:
        type: TokenEntity
        json_key: token
        required: true
      clinicalHistory:
        type: List<ClinicalHistoryEntity>?
        json_key: clinical_history
        required: false
    notes:
      - Wraps the full login response.
      - clinicalHistory is nullable because on auto re-login the list might not be needed.

  - name: ClinicalHistoryServiceEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_service_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      code:
        type: String
        json_key: code
        required: true
      name:
        type: String
        json_key: name
        required: true
      category:
        type: String
        json_key: category
        required: true

  - name: ClinicalHistoryFacilityEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_facility_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      id:
        type: String
        json_key: id
        required: true
      name:
        type: String
        json_key: name
        required: true
      city:
        type: String
        json_key: city
        required: true

  - name: ClinicalHistoryProfessionalEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_professional_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      id:
        type: String
        json_key: id
        required: true
      fullname:
        type: String
        json_key: fullname
        required: true
      specialty:
        type: String
        json_key: specialty
        required: true

  - name: ClinicalHistoryDiagnosisEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_diagnosis_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      code:
        type: String
        json_key: code
        required: true
      name:
        type: String
        json_key: name
        required: true

  - name: ClinicalHistoryAttachmentEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_attachment_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      id:
        type: String
        json_key: id
        required: true
      type:
        type: String
        json_key: type
        required: true
      name:
        type: String
        json_key: name
        required: true
      sizeBytes:
        type: int
        json_key: size_bytes
        required: true
      url:
        type: String
        json_key: url
        required: true

  - name: ClinicalHistoryStateEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_state_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      code:
        type: String
        json_key: code
        required: true
      label:
        type: String
        json_key: label
        required: true

  - name: ClinicalHistoryEntity
    layer: domain
    file: shared/models/clinical_history/clinical_history_entity.dart
    annotations: ["@freezed", "@JsonSerializable"]
    fields:
      id:
        type: String
        json_key: id
        required: true
      encounterNumber:
        type: String
        json_key: encounter_number
        required: true
      service:
        type: ClinicalHistoryServiceEntity
        json_key: service
        required: true
      facility:
        type: ClinicalHistoryFacilityEntity
        json_key: facility
        required: true
      professional:
        type: ClinicalHistoryProfessionalEntity?
        json_key: professional
        required: false
      encounterDate:
        type: String
        json_key: encounter_date
        required: true
      createdAt:
        type: DateTime?
        json_key: created_at
        required: false
      updatedAt:
        type: DateTime?
        json_key: updated_at
        required: false
      publishedAt:
        type: DateTime?
        json_key: published_at
        required: false
      summary:
        type: String?
        json_key: summary
        required: false
      description:
        type: String?
        json_key: description
        required: false
      diagnosis:
        type: List<ClinicalHistoryDiagnosisEntity>
        json_key: diagnosis
        required: true
      observations:
        type: List<String>
        json_key: observations
        required: true
      attachments:
        type: List<ClinicalHistoryAttachmentEntity>
        json_key: attachments
        required: true
      state:
        type: ClinicalHistoryStateEntity?
        json_key: state
        required: false
    notes:
      - Stored in sembast via CustomDb.clinicalHistory.
      - Contains nested sub-entities for service, facility, professional, diagnosis, attachments, and state.

  - name: AuthState
    layer: presentation
    file: features/auth/presentation/notifiers/auth_state.dart
    annotations: ["@freezed", "sealed"]
    variants:
      AuthInitial:
        fields: none
        description: Initial idle state, user not authenticated.
      AuthLoading:
        fields: none
        description: Login or auto-auth is in progress.
      AuthLoaded:
        fields:
          patient: PatientEntity
          token: TokenEntity
          clinicalHistory: List<ClinicalHistoryEntity>?
        description: User is authenticated.
      AuthFailure:
        fields:
          message: String
        description: Authentication failed with an error message.

interfaces:
  - name: IAuthRemoteDatasource
    file: features/auth/domain/datasources/i_auth_datasource.dart
    methods:
      - signature: "Future<LoginResponseEntity> login({required String email, required String passwordHash})"
      - signature: "Future<TokenEntity> refreshToken({required String token})"
    notes:
      - Remote (API) datasource for auth endpoints.

  - name: ILocalAuthDatasource
    file: features/auth/domain/datasources/i_local_auth_datasource.dart
    methods:
      - signature: "Future<void> saveSession({required LoginResponseEntity data, required String email, required String passwordHash})"
      - signature: "Future<void> clearSession()"
      - signature: "Future<LoginResponseEntity?> restoreSession()"
    notes:
      - Local datasource for session persistence (sembast + secure storage).
      - Methods do not return Either — the wrapping happens in AuthRepositoryImpl via guard().

  - name: IAuthRepository
    file: features/auth/domain/repositories/i_auth_repository.dart
    methods:
      - signature: "Future<Either<Failure, LoginResponseEntity>> login({required String email, required String passwordHash})"
      - signature: "Future<Either<Failure, TokenEntity>> refreshToken({required String token})"
      - signature: "Future<Either<Failure, void>> saveSession({required LoginResponseEntity data, required String email, required String passwordHash})"
      - signature: "Future<Either<Failure, void>> clearSession()"
      - signature: "Future<Either<Failure, LoginResponseEntity?>> restoreSession()"

usecases:
  - name: LoginUseCase
    constructor_args:
      - repository: IAuthRepository
    methods:
      - signature: "Future<Either<Failure, LoginResponseEntity>> call({required String email, required String passwordHash})"

  - name: RefreshTokenUseCase
    constructor_args:
      - repository: IAuthRepository
    methods:
      - signature: "Future<Either<Failure, TokenEntity>> call({required String token})"

  - name: SaveSessionUseCase
    constructor_args:
      - repository: IAuthRepository
    methods:
      - signature: "Future<Either<Failure, void>> call({required LoginResponseEntity data, required String email, required String passwordHash})"
    notes:
      - Persists patient info, clinical history, and credentials to local storage for remember-me.
      - All storage operations are wrapped via IAuthRepository.saveSession.

  - name: ClearSessionUseCase
    constructor_args:
      - repository: IAuthRepository
    methods:
      - signature: "Future<Either<Failure, void>> call()"
    notes:
      - Deletes all tokens and resets the database.
      - All cleanup operations are wrapped via IAuthRepository.clearSession.

  - name: RestoreSessionUseCase
    constructor_args:
      - repository: IAuthRepository
    methods:
      - signature: "Future<Either<Failure, LoginResponseEntity?>> call()"
    notes:
      - Loads patient info and token from local storage.
      - If token is expired, deletes all and returns null.
      - Returns null if no stored session exists.
