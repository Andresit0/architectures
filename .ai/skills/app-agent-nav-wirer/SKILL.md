---
name: app-agent-nav-wirer
description: Wires navigation for a feature: adds GoRoute to app_router.dart, adds AppRoute entry to app_route.dart, adds screen import, and adds navigation trigger to parent screen. Use after spec-dev Phase 10.
---

# Nav-Wirer Agent

You wire navigation for a newly created feature. You ensure the feature is accessible from the app.

---

## Skills and Context to Load

Before starting, load these resources in order:

1. **AGENTS.md** — read `AGENTS.md` at the project root. It contains:
   - `goRouterProvider` — `main.dart` uses `ref.watch(goRouterProvider)` from `app/di/router/router_provider.dart`
   - `ref.read(goRouterProvider).go(...)` pattern for navigation from features

2. **`MD/APP_PACKAGE_WRAPPER.md`** — specifically the "GoRouter (Riverpod)" category.

3. **`MD/APP_TREE.md`** — current file tree to identify the correct parent screens.

---

## Memory Protocol

### Before starting work

```
mem_search(query: "navigation wiring <feature_name>")
mem_search(query: "AppRoute route pattern")
mem_context()
```

Load prior knowledge about:
- Existing routes and AppRoute conventions in this project
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
  content: "What: Wired navigation for <feature>. Why: Required for feature accessibility. Where: app_route.dart, app_router.dart, parent_screen.dart. Learned: <any gotchas>"
)
```

---

## Mission

Wire all navigation elements for `<feature_name>`. Check each step and fix if missing.

---

## Step 1: Check existing wiring

```bash
grep "<feature_name>" lib/app/router/app_router.dart
grep "<feature_name>" lib/app/router/app_route.dart
```

If any grep returns empty → the element is missing, add it.

---

## Step 2: Add missing elements

### 2.1 Add AppRoute entry (app_route.dart)

Read `lib/app/router/app_route.dart` and add:

```dart
<featureName>(path: '/<path>', name: '<feature_name>'),
```

### 2.2 Add GoRoute + screen import (app_router.dart)

Read `lib/app/router/app_router.dart` and add the screen import at the top:

```dart
import 'package:clean_architecture_sdd_harness/features/<feature_name>/presentation/screens/<feature_name>_screen.dart';
```

Then add the GoRoute:

```dart
GoRoute(
  path: AppRoute.<featureName>.path,
  name: AppRoute.<featureName>.name,
  builder: (context, state) => const <FeatureName>Screen(),
),
```

For routes with parameters:
```dart
GoRoute(
  path: AppRoute.<featureName>.path,
  name: AppRoute.<featureName>.name,
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return <FeatureName>Screen(id: id);
  },
),
```

### 2.3 Add navigation trigger to parent screen

If the feature is navigated from a parent screen (e.g., `[parent_feature]` → `[child_feature]`), check the parent screen:

```bash
grep "goRouter" lib/features/<parent>/presentation/screens/<parent>_screen.dart
```

If no trigger exists, read the parent screen and add:

```dart
IconButton(
  tooltip: '<Tooltip>',
  icon: const Icon(Icons.<icon>),
  onPressed: () => ref.read(goRouterProvider).push(
    '/<feature_name>',
  ),
),
```

**CRITICAL:** Features navigate via `ref.read(goRouterProvider).go/push(path)` — NEVER import `go_router` directly in feature files.

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
- Check that the route path matches the AppRoute entry in `app_route.dart`
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
