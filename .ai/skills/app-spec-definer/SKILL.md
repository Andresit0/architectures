---
name: app-spec-definer
description: Orchestrates the complete Spec-Definer workflow for this project. Drives the spec-definition conversation (SDD + BDD + TDD), then writes all specification artifacts to lib/features/<feature_name>/spec/. Invoked by the Spec-Local orchestrator — do NOT call directly in response to feature requests ("new feature", "I want to build", etc.). Call directly only when the user explicitly says "run app-spec-definer directly" or "load skill app-spec-definer".
---

# Spec-Definer Agent

## Role

A dual-mode agent (standalone and subagent) that transforms a feature idea into a complete, versioned specification package stored in `lib/features/<feature_name>/spec/`. Always run this agent before writing any Dart code for a new feature.

## Modes

### Standalone

The agent drives a full collaborative conversation using the `spec-definition` skill workflow, collects user answers, then writes the output files.

### Subagent

Accepts a pre-filled user story and an optional answers map. Skips the interactive refinement phase and jumps directly to artifact generation and file writing.

---

## Workflow

### Phase 1 — Discovery (spec-definition skill)

Load and execute every step from `.ai/skills/app-spec-definition/SKILL.md`:

1. Receive the user story in any form. If the user includes a JSON payload, extract and store it as `_json_sample`; if not, ask: "Do you have a sample JSON response from the API for this feature? Paste it here or type 'none'."
2. Produce 8–15 numbered functional assumptions covering: scope, behavior, UX flows, business rules, edge cases, user roles, data involved, integrations, error handling, success criteria
3. Collect the user's objection numbers
4. Refine each flagged assumption one by one using the progress-bar format and exactly four concrete options plus Other
5. After all refinements signal readiness: "I've incorporated all your clarifications. I'm ready to create the specification whenever you say the word."

### Phase 2 — Feature name confirmation

Derive the feature folder name from the confirmed spec:

- Format: snake_case English noun phrase
- Examples: `auth_login`, `encounter_pdf_download`, `patient_profile`, `appointment_booking`
- The name must match the intended `lib/features/<name>/` directory name
- Present the name to the user and ask for confirmation before writing any file

### Phase 3 — Artifact generation

Generate all six artifacts from the confirmed and refined spec:

| Artifact | File | Format |
|---|---|---|
| SDD Specification | `spec.md` | YAML inside markdown fenced block |
| BDD Scenarios | `bdd.feature` | Gherkin plain text |
| TDD Test Plan | `tests.md` | YAML inside markdown fenced block |
| API Contracts | `contracts.md` | YAML inside markdown fenced block |
| Domain Models | `domain.md` | YAML inside markdown fenced block |
| Task Checklist | `tasks.md` | Markdown checkbox list |

### Phase 3.5 — JSON mock file (only when `_json_sample` was provided)

When the user supplied a JSON payload during Phase 1, perform these steps **before** writing the spec files:

1. **Derive names** from the feature name:
   - Class name: `<FeatureName>Json` (PascalCase, e.g. `AppointmentsJson`)
   - File name: `<feature_name>_json.dart` (snake_case, e.g. `appointments_json.dart`)
   - Facade member: `<featureName>Json` (camelCase, e.g. `appointmentsJson`)
   - Getter name: derive from the API call or feature purpose (e.g. `getAppointmentsResponse200`)

2. **Read** `lib/shared/jsons/_jsons.dart` and `lib/shared/jsons/_jsons.lib.dart` to understand the existing pattern before writing.

3. **Create** `lib/shared/jsons/<feature_name>_json.dart`:
   ```dart
   part of '_jsons.lib.dart';

   class <FeatureName>Json {
     Map<String, dynamic> get <getterName> => <paste the JSON payload as a Dart map literal>;
   }
   ```

4. **Update** `lib/shared/jsons/_jsons.lib.dart` — add the new part directive in alphabetical order:
   ```dart
   part '<feature_name>_json.dart';
   ```

5. **Update** `lib/shared/jsons/_jsons.dart` — add a new static final member to `CustomJsons` in alphabetical order:
   ```dart
   static final <FeatureName>Json <featureName>Json = <FeatureName>Json();
   ```

6. After writing these three files confirm:
   ```
   JSON mock data written to:
     lib/shared/jsons/<feature_name>_json.dart

   Barrel files updated:
     lib/shared/jsons/_jsons.lib.dart   (added: part '<feature_name>_json.dart')
     lib/shared/jsons/_jsons.dart       (added: CustomJsons.<featureName>Json)
   ```

### Phase 4 — Write files

Create the directory `lib/features/<feature_name>/spec/` and write each artifact as a separate file. After writing confirm to the user:

```
Specification written to lib/features/<feature_name>/spec/
  spec.md          SDD functional specification
  bdd.feature      BDD Gherkin scenarios
  tests.md         TDD test plan
  contracts.md     API contracts
  domain.md        Domain models and interfaces
  tasks.md         Implementation task checklist
```

If a JSON mock file was created in Phase 3.5, include it in the confirmation:

```
JSON mock data written to:
  lib/shared/jsons/<feature_name>_json.dart

Barrel files updated:
  lib/shared/jsons/_jsons.lib.dart
  lib/shared/jsons/_jsons.dart
```

---

## Artifact Formats

Reference the existing examples in `lib/features/auth/spec/` and `lib/features/encounter/spec/` to calibrate the level of detail required for each file in this project.

### spec.md

```yaml
feature: <snake_case_name>
actors:
  - <actor>
description: <one-line description of what the feature does and for whom>
rules:
  - <business rule stated as a fact>
flows:
  - name: <flow_name>
    steps:
      - <step>
edge_cases:
  - <edge case>
success_criteria:
  - <measurable outcome>
```

### bdd.feature

```gherkin
Feature: <Feature Name>

  Background:
    Given <common context that applies to all scenarios>

  Scenario: <Happy path name>
    Given <precondition>
    When <user action>
    Then <observable outcome>
    And <additional assertion>

  Scenario: <Error path name>
    Given <error precondition>
    When <action>
    Then <error outcome>
```

### tests.md

```yaml
tests:
  unit:
    - name: <snake_case_test_name>
      layer: domain | infrastructure | presentation
      given: <precondition in plain English>
      when: <action in plain English>
      then: <expected result in plain English>
  widget:
    - name: <snake_case_test_name>
      given: <widget setup>
      when: <user interaction>
      then: <visual or behavioral outcome>
  integration:
    - name: <snake_case_test_name>
      scenario: <BDD Scenario name this test covers>
      fake_repositories:
        - <IRepositoryInterfaceName>
      given: <app boots with fake repositories and user logs in>
      when: <navigation and interaction steps>
      then: <observable screen outcome>
```

### contracts.md

```yaml
endpoints:
  - method: GET | POST | PUT | PATCH | DELETE
    path: /path/{param}
    path_params:
      param:
        type: string
        description: <description>
        required: true
    request:
      headers:
        Header-Name: <value or format description>
      body:
        field:
          type: <type>
          required: true | false
          validation: <constraints>
    responses:
      200:
        field:
          type: <type>
          description: <description>
      4xx:
        error:
          type: string
          value: <error_code>
    timeout: <duration>
    auth: none | bearer_token
    notes:
      - <implementation note relevant to the datasource or mapper>
```

### domain.md

```yaml
models:
  - name: <EntityName>
    layer: domain
    file: features/<name>/domain/entities/<entity>.dart
    annotations:
      - "@freezed"
      - "@JsonSerializable"
    fields:
      <field_name>:
        type: <DartType>
        json_key: <json_key>
        required: true | false
        description: <description>
    computed:
      <getter_name>:
        type: <DartType>
        logic: <Dart expression>
        description: <description>
    notes:
      - "Import this entity directly — do NOT create a _entities.lib.dart barrel with library+part for @freezed files (causes Dart analyzer issues)"

  - name: <StateName>
    layer: presentation
    file: features/<name>/presentation/notifiers/<name>_state.dart
    annotations:
      - "@freezed"
      - "sealed"
    variants:
      <VariantName>:
        fields: none | <field_name>: <type>
        description: <description>
    notifier:
      type: non_family
      load_method: "Future<void> load(<args>)"
      notes: "Always non-family. Parameters are received via load(<args>) called from screen initState via addPostFrameCallback."

interfaces:
  - name: I<Name>Datasource
    file: features/<name>/domain/datasources/i_<name>_datasource.dart
    methods:
      - signature: "<return_type> <method>(<args>)"
        description: <description>
  - name: I<Name>Repository
    file: features/<name>/domain/repositories/i_<name>_repository.dart
    methods:
      - signature: "Future<Either<Failure, T>> <method>(<args>)"
        description: <description>

usecases:
  - name: <Name>UseCase
    file: features/<name>/domain/usecases/<name>_usecase.dart
    constructor_args:
      - repository: I<Name>Repository
    methods:
      - signature: "<return_type> call(<args>)"
        description: <description>
```

### tasks.md

```md
## <Feature Display Name> — Implementation Tasks

### Domain
- [ ] Define I<Name>Datasource interface
- [ ] Create <Name>Entity with @freezed and @JsonSerializable
- [ ] Define I<Name>Repository interface
- [ ] Create <Name>UseCase

### Infrastructure
- [ ] Implement <Name>DatasourceImpl
- [ ] Create <Name>Mapper
- [ ] Implement <Name>RepositoryImpl

### Presentation
- [ ] Create <Name>State sealed class
- [ ] Create <Name>Notifier with primary action and reset methods
- [ ] Create Riverpod DI chain providers
- [ ] Create <Name>Screen
- [ ] Create feature widgets

### Shared dependencies used
- [ ] Document each CustomProviders.xxx and CustomFunction.xxx dependency used

### Tests
- [ ] Unit: <Name>UseCase
- [ ] Unit: <Name>RepositoryImpl
- [ ] Unit: <Name>DatasourceImpl
- [ ] Unit: <Name>Notifier
- [ ] Unit: <Name>Entity computed getters
- [ ] Widget: <Name>Screen
- [ ] Integration: <BDD scenario name> (<IRepositoryInterface> fake)
```

---

## Constraints

- The `spec/` folder must always be placed inside `lib/features/<feature_name>/` and nowhere else
- Feature folder names must be English and snake_case
- Do not write any Dart code; this agent produces specification documents only
- Do not reference specific framework class names (Riverpod, Flutter, Drift) inside `spec.md` and `bdd.feature`; those files are purely functional
- Domain model names, interface names, and usecase names in `domain.md` and `tasks.md` must follow the project naming conventions documented in `MD/APP_ARCHITECTURE.md`
- All business rules in `spec.md` must describe behavior and outcomes, not implementation details
- API contracts in `contracts.md` must document all headers, response shapes, and timeout values because the infrastructure layer reads this file directly
- Test names in `tests.md` must follow the pattern `<subject>_<condition>_<expectation>` in snake_case

---

## Project conventions to apply in artifacts

Read `MD/APP_ARCHITECTURE.md` before generating artifacts to apply the correct layer names, file paths, and naming conventions.

Key conventions:
- Layer paths: `domain/`, `infrastructure/`, `presentation/`
- Interface prefix: `I<Name>Datasource`, `I<Name>Repository`
- State sealed class variants: `<Name>Initial`, `<Name>Loading`, `<Name>Success`, `<Name>Failure` or domain-specific names like `<Name>Idle`, `<Name>Downloading`
- Shared providers access: `CustomProviders.dio`, `CustomProviders.token`, `CustomProviders.sharePlus`, `CustomProviders.user`
- Failure conversion: `CustomFunction.fpdart.guard()` at repository boundary
- Error mapping: `CustomFunction.failure.launch()` in notifier fold

---

## Integration with coding agents

After the spec is written, the following agents read the spec folder:

| Spec file | Consumed by |
|---|---|
| `spec.md` | `class_to_solid` skill when scaffolding the feature architecture |
| `domain.md` | `class_to_solid` skill when creating entities, interfaces, and usecases |
| `contracts.md` | Infrastructure layer implementation (datasource endpoint, headers, timeout) |
| `bdd.feature` | `test-driven-development` skill when writing BDD-style tests |
| `tests.md` | `test-driven-development` skill when writing unit and widget tests |
| `tasks.md` | TodoWrite tool for tracking implementation progress |
| All six files | `spec-dev` skill (`.ai/skills/spec-dev/SKILL.md`) for full end-to-end TDD implementation |

When handing off to an implementing agent pass the full path `lib/features/<name>/spec/` so the agent reads all six artifacts before writing code.
