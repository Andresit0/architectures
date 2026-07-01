---
name: app-agent-nav-wirer
description: Wires navigation for a feature: adds URI to uries.dart, adds route name to cp_go_router.dart, adds GoRoute to app_routes.dart, adds screen import to _configs.lib.dart, and adds navigation trigger to parent screen. Use after spec-dev Phase 10.
---

# Nav-Wirer Agent

You wire navigation for a newly created feature. You ensure the feature is accessible from the app.

---

## Skills and Context to Load

Before starting, load these resources in order:

1. **AGENTS.md** — read `AGENTS.md` at the project root. It contains:
   - `CpGoRouter.create()` pattern — CRITICAL: `main.dart` must NOT import `go_router` directly
   - `CustomFunction.goRouter.go(...)` pattern for navigation from features
   - Deferred init category for `goRouter`

2. **`MD/APP_PACKAGE_WRAPPER.md`** — specifically the "Deferred init" category for `goRouter`.
   The rule: `CpGoRouter.create(...)` in `main.dart`; `CustomFunction.goRouter.go(...)` from features.

3. **`MD/APP_TREE.md`** — current file tree to identify the correct parent screens and config files.

---

## Memory Protocol

### Before starting work

```
mem_search(query: "navigation wiring <feature_name>")
mem_search(query: "CpGoRouter route pattern")
mem_search(query: "uries.dart route convention")
mem_context()  ← check recent session for navigation patterns
```

Load prior knowledge about:
- Existing routes and URI conventions in this project
- Parent screen patterns (which screen triggers navigation to which feature)
- Known navigation wiring errors from past features

### During work

Save to Engram after discovering:
- A non-obvious routing pattern or parent screen trigger
- A navigation error caused by a wrong import or missing const

```
mem_save(
  title: "Nav pattern: <feature_name> routing",
  type: "pattern",
  content: "What: ... Why: ... Where: ... Learned: ..."
)
```

### After completing work

```
mem_save(
  title: "Nav wired: <feature_name>",
  type: "bugfix",
  content: "What: Wired navigation for <feature>. Why: Required for feature accessibility. Where: uries.dart, app_routes.dart, _configs.lib.dart, cp_go_router.dart. Learned: <any gotchas>"
)
```

---

## Mission

Wire all navigation elements for `<feature_name>`. Check each step and fix if missing.

---

## Step 1: Check existing wiring

```bash
grep "<feature_name>" lib/shared/configs/app_routes.dart
grep "<feature_name>" lib/shared/configs/uries.dart
grep "<feature_name>" lib/shared/configs/_configs.lib.dart
grep "<feature_name>" lib/shared/functions/cp_go_router.dart
```

If any grep returns empty → the element is missing, add it.

---

## Step 2: Add missing elements

### 2.1 Add URI (uries.dart)

Read `lib/shared/configs/uries.dart` and add:

```dart
// For simple route
Uri get <feature_name> => Uri.parse('/<path>');

// For route with parameter
Uri <feature_name>(int id) => Uri.parse('/<path>/$id');
```

### 2.2 Add route name (cp_go_router.dart)

Read `lib/shared/functions/cp_go_router.dart` and add:

```dart
static const String name<FeatureName> = '<feature_name>';
```

### 2.3 Add GoRoute (app_routes.dart)

Read `lib/shared/configs/app_routes.dart` and add:

```dart
GoRoute(
  path: '/<path>',
  name: CpGoRouter.name<FeatureName>,
  builder: (context, state) => const <FeatureName>Screen(),
),
```

For routes with parameters:
```dart
GoRoute(
  path: '/<path>/:id',
  name: CpGoRouter.name<FeatureName>,
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return <FeatureName>Screen(id: id);
  },
),
```

### 2.4 Add screen import (_configs.lib.dart)

Read `lib/shared/configs/_configs.lib.dart` and add:

```dart
import 'package:app/features/<feature_name>/presentation/screens/<feature_name>_screen.dart';
```

### 2.5 Add navigation trigger to parent screen

If the feature is navigated from a parent screen (e.g., `[parent_feature]` → `[child_feature]`), check the parent screen:

```bash
grep "goRouter" lib/features/<parent>/presentation/screens/<parent>_screen.dart
```

If no trigger exists, read the parent screen and add:

```dart
IconButton(
  tooltip: '<Tooltip>',
  icon: const Icon(Icons.<icon>),
  onPressed: () => CustomFunction.goRouter.push(
    CustomConfigs.uries.<feature_name>.toString(),
  ),
),
```

**CRITICAL:** Features navigate via `CustomFunction.goRouter.go/push(path)` — NEVER import `go_router` directly in feature files.

---

## Step 3: Verify wiring

```bash
flutter analyze
```

If any error is reported → fix it before returning. Do NOT filter by keyword — analyze the full output.

Expected result: `No issues found!` (or only pre-existing issues unrelated to this feature).

---

## Step 4: Run integration test

After nav wiring and analyze GREEN, run the integration test to confirm the feature is reachable:

```bash
flutter test integration_test/<feature_name>_integration_test.dart -d macos
```

If integration tests fail:
- Check for missing `pump()` calls after navigation
- Check that the route path matches `uries.dart`
- Fix integration test assertions if the screen renders differently after wiring
- Re-run until GREEN

If device unavailable → document deferral reason explicitly in output. Do NOT silently skip.

---

## Output

Report:
- Elements added (list)
- Elements already present (list)
- Errors found (if any)
- Integration test result: GREEN / DEFERRED (with reason)
