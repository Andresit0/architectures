# spec-dev Phase Gate — Execution Checklist

## Purpose

This file is a **mandatory gate** that runs AT THE START of each spec-dev phase. If any step is not met, execution stops and it is reported.

The file lives at:
- `.ai/orchestrators/spec-dev-phases-checklist.md`

---

## Execution by Phase

Each phase has a checklist. Before moving to the next phase, ALL items must be checked ✅ or explicitly executed.

---

## Phase 0 — Context Gathering

**BEFORE writing any code**, read these files in order:

```
[ ] 0.1  Read the 6 spec folder files:
        <spec>/spec.md
        <spec>/domain.md
        <spec>/contracts.md
        <spec>/bdd.feature
        <spec>/tests.md
        <spec>/tasks.md

[ ] 0.2  Read the 7 project context files:
        MD/APP_ARCHITECTURE.md
        MD/APP_BARREL_PATTERN.md
        MD/APP_TREE.md
        MD/APP_DARTZ.md
        MD/APP_PACKAGE_WRAPPER.md
        MD/APP_PROVIDERS.md
        AGENTS.md

[ ] 0.3  Read shared configuration files:
        lib/core/network/api_endpoints.dart
        lib/app/router/app_route.dart
        lib/app/router/app_router.dart

[ ] 0.4  Read the reference feature:
        lib/features/[feature_name]/domain/entities/[feature_name]_entity.dart
        lib/features/[feature_name]/infrastructure/datasources/[feature_name]_datasource_impl.dart
        lib/features/[feature_name]/infrastructure/repositories/[feature_name]_repository_impl.dart
        lib/features/[feature_name]/presentation/notifiers/[feature_name]_state.dart
        lib/features/[feature_name]/presentation/notifiers/[feature_name]_notifier.dart
        lib/features/[feature_name]/di/[feature_name]_provider.dart
        lib/features/[feature_name]/presentation/screens/[feature_name]_screen.dart
        lib/features/[feature_name]/presentation/widgets/_widgets.lib.dart
        integration_test/[feature_name]_integration_test.dart

[ ] 0.5  Create todowrite with ALL items from <spec>/tasks.md
```

---

## Phase 1 — Domain Entities + build_runner

```
[ ] 1.1  Create domain/entities/*.dart for each entity in domain.md
        (including @freezed + @JsonSerializable where applicable)

[ ] 1.2  Run: dart run build_runner build --delete-conflicting-outputs
        

[ ] 1.3  Create DTOs (infrastructure/dtos/)

[ ] 1.4  Verify .freezed.dart and .g.dart exist for each entity

[ ] 1.5  IMPORTANT: Do NOT create _entities.lib.dart with library+part for @freezed
```

---

## Phase 2 — Domain Stubs → RED

```
[ ] 2.1  Create domain/datasources/i_<name>_datasource.dart (stub with UnimplementedError)

[ ] 2.2  Create domain/repositories/i_<name>_repository.dart (stub with UnimplementedError)

[ ] 2.3  Create domain/usecases/<name>_usecase.dart (stub with UnimplementedError)

[ ] 2.4  Write unit tests at:
        test/features/<feature>/domain/<name>_usecase_test.dart
        test/features/<feature>/domain/<name>_entity_test.dart

[ ] 2.5  Run: flutter test test/features/<feature>/domain/
        EXPECTED: usecase tests FAIL with UnimplementedError
        If all pass → ERROR: stubs don't have UnimplementedError
```

---

## Phase 3 — Domain Implementation → GREEN

```
[ ] 3.1  Replace throw UnimplementedError() with correct logic in usecases

[ ] 3.2  Run: flutter test test/features/<feature>/domain/
        EXPECTED: all GREEN
```

---

## Phase 4 — Infrastructure Stubs → RED

```
[ ] 4.1  IMPORTANT: create infrastructure/ even if the spec says "reuse existing datasource".
        The infrastructure/ folder MUST ALWAYS exist with its own structure.
        (The lab_results_chart feature omitted this folder and broke the complete pattern)

[ ] 4.2  Create infrastructure/datasources/<name>_datasource_impl.dart (stub UnimplementedError)

[ ] 4.3  Create infrastructure/mappers/<name>_mapper.dart (stub UnimplementedError)

[ ] 4.4  Create infrastructure/repositories/<name>_repository_impl.dart (stub UnimplementedError)

[ ] 4.5  Write tests at:
        test/features/<feature>/infrastructure/<name>_repository_test.dart
        test/features/<feature>/infrastructure/<name>_datasource_test.dart

[ ] 4.6  Run: flutter test test/features/<feature>/infrastructure/
        EXPECTED: all FAIL with UnimplementedError
```

---

## Phase 5 — Infrastructure Implementation → GREEN

```
[ ] 5.1  Implement datasource (pure HTTP — no mock conditional inside datasource)
        FakeDatasource is a separate file at infrastructure/datasources/fake_*_datasource.dart
        Provider returns DatasourceImpl directly: @riverpod IDatasource datasource(Ref ref) => DatasourceImpl(dio: ...)

[ ] 5.2  Implement mapper (named constructors from DTO, VGV-standard)

[ ] 5.3  Implement repository with guard() from shared/error/result_guard.dart
        NEVER use raw try/catch

[ ] 5.4  Run: flutter test test/features/<feature>/infrastructure/
        EXPECTED: all GREEN
```

---

## Phase 6 — State + Notifier + Providers + codegen

```
[ ] 6.1  Create presentation/notifiers/<name>_state.dart (@freezed sealed class)

[ ] 6.2  Create presentation/notifiers/<name>_notifier.dart (@riverpod, stub load())

[ ] 6.3  Create di/<name>_provider.dart (DI chain — moved from presentation/providers/)

[ ] 6.4  Run: dart run build_runner build --delete-conflicting-outputs
        

[ ] 6.5  Verify .freezed.dart exists for state and .g.dart for notifier/provider
```

---

## Phase 7 — Presentation Tests → RED

```
[ ] 7.1  Write notifier tests at:
        test/features/<feature>/presentation/notifiers/<name>_notifier_test.dart

[ ] 7.2  Write screen tests at:
        test/features/<feature>/presentation/screens/<name>_screen_test.dart

[ ] 7.3  Write widget tests at:
        test/features/<feature>/presentation/widgets/<name>_widget_test.dart

[ ] 7.4  Run: flutter test test/features/<feature>/presentation/
        EXPECTED: tests FAIL (stub load() doesn't make state transition)
```

---

## Phase 8 — Presentation Implementation → GREEN

```
[ ] 8.1  Implement notifier — state passes AppError via AuthState.failure(error)

[ ] 8.2  Implement screen (ConsumerStatefulWidget + ref.watch + ref.listen)

[ ] 8.3  Create individual widgets in presentation/widgets/

[ ] 8.4  Run: flutter test test/features/<feature>/presentation/
        EXPECTED: all GREEN
```

---

## Phase 9 — Integration Test

```
[ ] 9.1  Create integration_test/<feature>_integration_test.dart
        (one for each Scenario in bdd.feature)

[ ] 9.2  Run: flutter analyze integration_test/<feature>_integration_test.dart
        EXPECTED: 0 issues
        (may have errors if screen is not imported in _configs.lib.dart — that is OK,
        will be fixed in Phase 10)
```

---

## Phase 9.5 — BDD Step Definitions (gherkart)

```
[ ] 9.5.1  Verify gherkart is in dev_dependencies of pubspec.yaml
        If not: run flutter pub add dev:gherkart 

[ ] 9.5.2  Create test/bdd/<feature>_bdd_test.dart
        CRITICAL: _testFunction MUST be top-level named function, NOT inline lambda

[ ] 9.5.3  Run: flutter test test/bdd/<feature>_bdd_test.dart
        EXPECTED: all GREEN
```

---

## Phase 10 — Barrels + Navigation + build_runner

```
[ ] 10.1  Run barrel skill for presentation/widgets/
        → Create _widgets.lib.dart + _widgets.dart

[ ] 10.2  Add AppRoute entry in lib/app/router/app_route.dart

[ ] 10.3  Add GoRoute + screen import in lib/app/router/app_router.dart

[ ] 10.4  [Removed — route registration consolidated in steps 10.2-10.3]

[ ] 10.5  [Removed — screen import goes directly in app_router.dart]

[ ] 10.6  If the spec says there is a navigation trigger in parent screen:
        → Add IconButton with ref.read(goRouterProvider).push() in that screen

[ ] 10.7  Run: dart run build_runner build --delete-conflicting-outputs
        

[ ] 10.8  Run: flutter analyze
        EXPECTED: 0 issues
```

---

## Phase 11 — Final Verification

```
[ ] 11.1  Run: flutter analyze
        EXPECTED: 0 issues

[ ] 11.2  Run: flutter test test/features/<feature>/
        EXPECTED: 0 failures

[ ] 11.3  Run: flutter test test/bdd/<feature>_bdd_test.dart
        EXPECTED: 0 failures

[ ] 11.4  Run integration test on device:
        → First: dart-mcp-server_list_devices
        → If device available: dart-mcp-server_run_tests with
          roots: [{root: "file:///path/to/project",
                   paths: ["integration_test/<feature>_integration_test.dart"]}]
        → If NO device: flutter analyze and document "deferred with reason"
```

---

## Post-verification — Orchestrator Phases

```
[ ] 12.1  Launch Update-MD agent to update:
        → MD/APP_TREE.md (new feature entry)
        → AGENTS.md (if applicable)

[ ] 12.2  Save in Engram:
        → mem_save with design decisions, patterns, gotchas
        → mem_session_summary at the end of the session
```

---

## Completion Criteria (verify all at the end)

```
□ spec folder has 6 files
□ spec-dev executed the 11 phases (all verification marks complete)
□ flutter analyze returns 0 issues
□ flutter test test/features/<feature>/ returns 0 failures
□ flutter test test/bdd/<feature>_bdd_test.dart returns 0 failures
□ integration test ran on device (or deferred with reason)
□ sdd-verify verdict: PASS or PASS WITH WARNINGS
□ MD/* updated
□ Engram has session summary
```

If any criterion is not met → the feature is NOT complete. Do not advance to another feature.
