# Plan: Clean Architecture Refactoring — de 8.0 a 9.2/10

## Resumen del Plan

6 fases secuenciales. Cada fase incluye los archivos exactos a modificar y el contenido esperado.

---

## FASE A: Eliminar toJson/fromJson de shared models + crear serializadores

### A1 — Crear directorio y serializadores

**Nuevo directorio:** `lib/core/database/serializers/`

**Archivo 1: `lib/core/database/serializers/patient_serializer.dart`**
- Clase `PatientSerializer` con `toMap()` y `fromMap()` estáticos
- Mapea `PatientEntity` ↔ `Map<String, dynamic>`

**Archivo 2: `lib/core/database/serializers/clinical_history_serializer.dart`**
- Clase `ClinicalHistorySerializer` con `toMap()` y `fromMap()` estáticos
- Mapea `ClinicalHistoryEntity` ↔ `Map<String, dynamic>` incluyendo las 6 sub-entidades anidadas

### A2 — Remover toJson/fromJson de 8 entidades

**Archivos a modificar (eliminar métodos `toJson()` y `factory fromJson()`):**

1. `lib/shared/models/patient/patient_entity.dart`
   - Eliminar `toJson()` y `fromJson()`
   
2. `lib/shared/models/clinical_history/clinical_history_entity.dart`
   - Eliminar `toJson()` y `fromJson()`
   - Eliminar `import 'package:collection/collection.dart'`

3. `lib/shared/models/clinical_history/clinical_history_service_entity.dart`
4. `lib/shared/models/clinical_history/clinical_history_facility_entity.dart`
5. `lib/shared/models/clinical_history/clinical_history_professional_entity.dart`
6. `lib/shared/models/clinical_history/clinical_history_diagnosis_entity.dart`
7. `lib/shared/models/clinical_history/clinical_history_attachment_entity.dart`
8. `lib/shared/models/clinical_history/clinical_history_state_entity.dart`

### A3 — Actualizar tablas de BD

**`lib/core/database/tables/patient_info.dart`:**
- Reemplazar `jsonDecode(jsonEncode(entity))` → `PatientSerializer.toMap(entity)`
- Reemplazar `PatientEntity.fromJson(Map...)` → `PatientSerializer.fromMap(map)`

**`lib/core/database/tables/clinical_history.dart`:**
- Reemplazar `jsonDecode(jsonEncode(entity))` → `ClinicalHistorySerializer.toMap(entity)`
- Reemplazar `ClinicalHistoryEntity.fromJson(Map...)` → `ClinicalHistorySerializer.fromMap(map)`
- Eliminar `import 'dart:convert'` (ya no necesita jsonEncode/jsonDecode)

### A4 — Actualizar AuthMapper

**`lib/features/auth/infrastructure/mappers/auth_mapper.dart`:**
- Reemplazar `PatientEntity.fromJson(json['patient'])` por construcción directa:
  ```dart
  final patientJson = json['patient'] as Map<String, dynamic>;
  patient: PatientEntity(id: patientJson['id'] as String, name: patientJson['name'] as String),
  ```
- Reemplazar `ClinicalHistoryEntity.fromJson(e)` por:
  ```dart
  .map((e) => ClinicalHistorySerializer.fromMap(e as Map<String, dynamic>)).toList(),
  ```
- Agregar import de `ClinicalHistorySerializer`

### A5 — Actualizar tests

**`test/shared/models/patient/patient_model_test.dart`:**
- Eliminar test `fromJson creates entity from JSON map`
- Agregar test `PatientSerializer toMap/fromMap roundtrip`

**`test/shared/models/clinical_history/clinical_history_model_test.dart`:**
- Eliminar 8 tests de `fromJson` (uno por cada entidad)
- Agregar tests de `ClinicalHistorySerializer` roundtrip

**`lib/core/database/_database.lib.dart`:**
- Agregar `export 'serializers/patient_serializer.dart';`
- Agregar `export 'serializers/clinical_history_serializer.dart';`

---

## FASE B: Agregar lógica de negocio a entidades

### B1 — TokenEntity

> **OBSOLETO:** `expirationDate` fue eliminado de `TokenEntity` (10-08-2024). La expiracion se determina via `JwtTokenExpiryChecker` leyendo el claim `exp` del JWT. Este bloque queda como referencia historica unicamente.

**`lib/features/auth/domain/entities/token_entity.dart`** — Agregar getters (OBSOLETO):

```dart
// Obsoleto - expirationDate fue eliminado de TokenEntity
```

### B2 — LoginResponseEntity

**`lib/features/auth/domain/entities/login_response_entity.dart`** — Agregar getters:

```dart
bool get hasClinicalHistory =>
    clinicalHistory != null && clinicalHistory!.isNotEmpty;

bool get isComplete =>
    patient.name.isNotEmpty && token.isValid;
```

### B3 — Agregar tests de lógica de negocio

**`test/features/auth/domain/auth_entity_test.dart`:**
- Agregar tests para `TokenEntity.isExpired`, `isValid`, `expiresSoon`
- Agregar tests para `LoginResponseEntity.hasClinicalHistory`, `isComplete`

---

## ~~FASE C: Eliminar useMockRepository flag~~ (COMPLETED — SUPERSEEDED)

Este plan fue supercedido por un refactor posterior que:
1. Elimino `CustomConfigs.vars` → reemplazado por `AppEnvironment` ✅
2. Elimino el patron `_useMock` del datasource → `AuthRemoteDatasourceImpl` es puramente HTTP ✅
3. Elimino `lib/shared/jsons/` (CustomJsons, _jsons.lib.dart, auth_json.dart) ✅
4. Creo `FakeAuthRemoteDatasource` en un archivo separado usando entity constructors ✅
5. El provider (`auth_provider.dart`) decide: `if (useMock) return FakeDatasource() else return DatasourceImpl(dio: ...)` ✅

Ver estado actual en la documentacion en `.ai/skills/` y `MD/`.

---

## FASE D: Corregir DI

### D1 — Replaced: ErrorPropagation → localizeError()

**Superseded by:**
- `errorPropagationProvider` was REMOVED. Its role (error-to-string mapping) was moved to `localizeError()` in `shared/error/error_localizer.dart`.
- UI code now calls `localizeError(error, AppLocalizations.of(context)!)` instead of `errorPropagation.launch(...)`.
- Notifiers pass `AppError` directly to state via `AuthState.failure(error)`.

### D3 — Inyectar AppDatabase en provider

**`lib/features/auth/presentation/providers/auth_provider.dart`:**
- Reemplazar `appDatabase: AppDatabase()` por un provider de AppDatabase
- O usar `ref.watch(sembastProvider)` si ya existe un provider adecuado

---

## FASE E: Reglas de lint arquitectónico

**`analysis_options.yaml`** — Agregar:

```yaml
analyzer:
  errors:
    # Evitar que features importen infraestructura de otras features
    invalid_import_of_other_feature: error

custom_lint:
  rules:
    - avoid_direct_package_imports_in_features
```

Nota: Esto puede requerir agregar `custom_lint` como dev_dependency. Evaluar si usar `custom_lint` o reglas nativas de Dart.

---

## FASE F: Verificación final

1. `flutter analyze` — debe dar 0 issues
2. `flutter test` — todos los tests deben pasar
3. `flutter test test/bdd/` — BDD tests verdes
4. Revisar que no queden imports de `package:collection` en shared models
5. Revisar que no queden `toJson`/`fromJson` en shared models

---

## Archivos nuevos (3)

| Archivo |
|---------|
| `lib/core/database/serializers/patient_serializer.dart` |
| `lib/core/database/serializers/clinical_history_serializer.dart` |

## Archivos modificados (~25)

| Archivo |
|---------|
| `lib/shared/models/patient/patient_entity.dart` |
| `lib/shared/models/clinical_history/clinical_history_entity.dart` |
| `lib/shared/models/clinical_history/clinical_history_diagnosis_entity.dart` |
| `lib/shared/models/clinical_history/clinical_history_state_entity.dart` |
| `lib/shared/models/clinical_history/clinical_history_service_entity.dart` |
| `lib/shared/models/clinical_history/clinical_history_professional_entity.dart` |
| `lib/shared/models/clinical_history/clinical_history_facility_entity.dart` |
| `lib/shared/models/clinical_history/clinical_history_attachment_entity.dart` |
| `lib/core/database/tables/patient_info.dart` |
| `lib/core/database/tables/clinical_history.dart` |
| `lib/core/database/_database.lib.dart` |
| `lib/features/auth/infrastructure/mappers/auth_mapper.dart` |
| `lib/features/auth/infrastructure/datasources/auth_datasource_impl.dart` |
| `lib/features/auth/domain/entities/token_entity.dart` |
| `lib/features/auth/domain/entities/login_response_entity.dart` |
| `lib/features/auth/presentation/notifiers/auth_notifier.dart` |
| `lib/features/auth/presentation/providers/auth_provider.dart` |
| `lib/core/providers/_providers.dart` |
| `lib/core/providers/_providers.lib.dart` |
| `test/shared/models/patient/patient_model_test.dart` |
| `test/shared/models/clinical_history/clinical_history_model_test.dart` |
| `test/features/auth/domain/auth_entity_test.dart` |
| `analysis_options.yaml` |

## Riesgos

- Los tests de `fromJson` se romperán al eliminar esos métodos — deben actualizarse simultáneamente
- La BD sembast usa `jsonEncode(entity)` que depende de `toJson()` — debe migrarse a serializadores
- El auth_mapper usa `PatientEntity.fromJson()` — debe migrarse a construcción directa o serializador
