---
name: app-agent-cp-package
description: Creates a <package>_wrapper.dart wrapper in lib/core/services/<domain>/ for a new pub package. Invoked by Spec-Local-Orchestrator when a missing wrapper is detected. Never call directly — use via orchestrator task().
---

# App Agent: Package Wrapper Creator

## Purpose

Sub-agent delegated by the Spec-Local-Orchestrator when a missing `<package>_wrapper.dart` is detected. The orchestrator MUST NOT create wrappers inline — it delegates via `task()` to this agent.

## Input

The orchestrator passes:
- **package_name**: exact pub.dev package name (e.g. `url_launcher`)
- **feature_name**: the feature that requires this wrapper (for context/logging)
- **minimal_api**: brief description of what methods/functionality to expose

## Rules (non-negotiable)

1. **NEVER** add `import 'package:<pkg>/...'` inside `<pkg>_wrapper.dart`. The wrapper is the SINGLE file that may import the package — no other file in the project imports it directly.
2. **Default values in constructors MUST be `const`** when the type supports it (e.g. `const Color(0xFF...)`, `const EdgeInsets.all(0)`).
3. **Run `flutter analyze lib/core/services/`** before returning. Zero issues required. **If analyze fails, fix all issues before proceeding — NEVER return with analyze errors.**
4. **STOP** if the wrapper already exists — do not overwrite. Report back to the orchestrator.
5. Apply SOLID interface pattern — **delegate to `app-class-to-solid-min`**:
   Read `.ai/skills/app-class-to-solid-min/SKILL.md` and follow it exactly for `<package_name>_wrapper.dart`.
   Concretely (sourced from that SKILL.md):
   a) In `<pkg>_wrapper.dart`, add `abstract interface class I<PkgName>Wrapper` ABOVE `class <PkgName>Wrapper`. The interface declares only the public method signatures — no bodies.
   b) Add `implements I<PkgName>Wrapper` to `<PkgName>Wrapper` and `@override` on every method.
   d) Run `flutter analyze lib/core/services/` → 0 issues required before returning. Fix any issues before proceeding.
   Do NOT create a Riverpod provider for UI-only / pure-utility wrappers (fl_chart, lottie, logger, etc.). Only injectable services (dio, token) get a provider — check `MD/APP_PACKAGE_WRAPPER.md`.
6. **THE WRAPPER IS A THIN FACADE — NOT BUSINESS LOGIC.** The wrapper must only re-expose the package's own public API (types, constructors, methods). It MUST NOT contain any domain logic, widget-building code, chart configuration, layout, styling, or data transformation. All of that belongs in the feature's presentation layer (widgets). If you find yourself writing `LineChart(...)`, `HorizontalLine(...)`, or any feature-specific rendering code inside the wrapper, you are violating this rule. Stop and delete that code.
7. **NEVER invent types.** Only use types that actually exist in the package. Before writing any type name, verify it exists in the package's exported API. Common failure mode: inventing `ChartDataPoint`, `LineChartBarSpot` as a constructor method, etc.

---

## Execution Steps

### Step 1 — Guard: wrapper already exists?

Check for `<package>_wrapper.dart` in the appropriate domain folder.

```
bash: find lib/core/services/ -name "<package>_wrapper.dart" 2>/dev/null
```

- **EXISTS** → Stop. Return: `ALREADY_EXISTS: <package>_wrapper.dart found at <path>. No changes made.`
- **MISSING** → Continue to Step 2.

---

### Step 2 — Guard: package already in pubspec.yaml?

Read `pubspec.yaml` and search for the package name under `dependencies:`.

- **FOUND** → Skip Step 3 (don't add it twice), continue to Step 4.
- **NOT FOUND** → Continue to Step 3.

---

### Step 3 — Add package to pubspec.yaml

```bash
dart pub add <package_name>
```

Verify exit code 0. If it fails, abort and report the error to the orchestrator.

---

### Step 4 — Create <package>_wrapper.dart

#### What goes in the wrapper (STRICT)

The wrapper is a **thin facade** that re-exposes the package's own public API.

**ALLOWED inside the wrapper:**
- Method signatures that delegate directly to the package (one-liners)
- Constructors that accept the package's own types as parameters
- Re-exporting package-level constants or enums if needed

**FORBIDDEN inside the wrapper (move to the feature's presentation layer instead):**
- Widget-building code of any kind (`LineChart(...)`, `Column(...)`, etc.)
- Domain logic or data transformations
- Layout, styling, chart configuration specific to a feature
- Types that do not exist in the package — NEVER invent types

> **Self-check before writing any line**: "Does this type/method exist in the package's exported API?"
> If unsure, check `~/.pub-cache/hosted/pub.dev/<package>-<version>/lib/` before writing.

#### Template

Create `<package>_wrapper.dart` in the appropriate `lib/core/services/<domain>/` folder:

```dart
abstract interface class I<PkgName>Wrapper {
  // Only methods the feature actually calls.
  // Each method delegates to the package — no logic here.
  // Example for url_launcher:
  //   Future<void> launch(String url);
}

class <PkgName>Wrapper implements I<PkgName>Wrapper {
  // One-liner implementations that call the real package API.
  // Example:
  //   @override
  //   Future<void> launch(String url) => launchUrl(Uri.parse(url));
}
```

**Naming rules:**
- File: `<package_name>_wrapper.dart` (snake_case, matching pub package name)
- Abstract class: `I` + PascalCase of package + `Wrapper` (e.g. `IUrlLauncherWrapper`)
- Concrete class: PascalCase of package + `Wrapper` (e.g. `UrlLauncherWrapper`)

**Pattern reference** (example for url_launcher as `lib/core/services/device/url_launcher_wrapper.dart`):
```dart
abstract interface class IUrlLauncherWrapper {
  Future<void> launch(String url);
}

class UrlLauncherWrapper implements IUrlLauncherWrapper {
  @override
  Future<void> launch(String url) async {
    await launchUrl(Uri.parse(url));
  }
}
```

**For UI-only packages** (e.g. `fl_chart`, `lottie`, `cached_network_image`) where the widget IS the API:

**CRITICAL RULE: The wrapper is the SINGLE file that may import the package. If any feature code needs to import the package to construct arguments for the wrapper, the wrapper is too thin — it leaks the package's type system into the project.**

The wrapper must accept only simple types (`double`, `int`, `String`, `bool`, `Color`, `List`, `Map`, `Set`, and Flutter/dart: types) and construct the package's complex types internally.

```dart
// CORRECT — wrapper is self-contained, feature never imports the package
abstract interface class IFlChartWrapper {
  Widget lineChart({
    required List<double> values,
    List<String>? labels,
    Color? lineColor,
    Color? fillColor,
  });
}

class FlChartWrapper implements IFlChartWrapper {
  @override
  Widget lineChart({
    required List<double> values,
    List<String>? labels,
    Color? lineColor,
    Color? fillColor,
  }) {
    final spots = values.asMap().entries
      .map((e) => FlSpot(e.key.toDouble(), e.value))
      .toList();
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(spots: spots, color: lineColor, ...),
      ],
      ...
    ));
  }
}

// WRONG — leaks package type into feature, forcing direct imports
class FlChartWrapper implements IFlChartWrapper {
  @override
  Widget lineChart(LineChartData data) => LineChart(data); // ← Feature must construct LineChartData → imports fl_chart
}
```

**What belongs in the wrapper (the boundary):**
- Converting simple inputs (`List<double>`, labels, colors) into the package's chart config types
- Setting sensible visual defaults (colors, sizes, paddings) — these are *wrapper defaults*, not business logic

**What belongs in the feature widget (caller):**
- Mapping domain entities to the simple values the wrapper expects (e.g. `VentaPorMesEntity` → `List<double>`)
- Business-logic-driven color decisions (red for negative, green for positive)
- Axis labels derived from domain data (month names, product names)

---

### Step 5 — Verify wrapper access pattern

The wrapper file (`<package>_wrapper.dart`) is a standalone file. It has its own `import` statements for the package it wraps.

Wrappers are accessed via Riverpod providers. Register the provider in `_providers.lib.dart` barrel if the service needs injection (category "Injectable service"). Consumer files access via:
```dart
ref.watch(<pkg>Provider)
```

---

### Step 7 — Run flutter analyze (BLOCKING)

```bash
flutter analyze lib/core/services/
```

- **0 issues** → proceed to Step 8.
- **Issues found** → **STOP. Fix every issue before proceeding. This is a hard gate.**

Common causes and fixes:

| Error | Fix |
|---|---|
| `The name 'X' isn't a type` | You invented a type that doesn't exist. Delete it. Check the package's actual exported types in `~/.pub-cache/hosted/pub.dev/<pkg>-<version>/lib/`. |
| `The method 'X' isn't defined` | You called a method that doesn't exist. Check the real API. |
| `Invalid constant value` | Remove `const` from the value or change the expression. |
| `Missing override annotation` | Add `@override` to all interface implementations. |
| `withOpacity is deprecated` | Replace `.withOpacity(x)` with `.withValues(alpha: x)`. |
| Method signature mismatch | Interface and impl must have identical signatures. |

Re-run `flutter analyze lib/core/services/` after each fix.
**Do NOT proceed to Step 8 until the output is exactly: `No issues found!`**

---

### Step 8 — Save to Engram

```
mem_save(
  title: "Wrapper creado: <package>_wrapper",
  type: "decision",
  content: """
    **What**: Created <package>_wrapper.dart wrapper
    **Why**: Required by feature '<feature_name>' — detected missing
    **Where**: lib/core/services/<domain>/<package>_wrapper.dart
    **Learned**: <any gotchas found during creation, or omit if none>
  """
)
```

---

### Step 9 — Return confirmation

Return a structured summary to the orchestrator:

```
WRAPPER_DONE

Package   : <package_name>
Feature   : <feature_name>
Files modified:
  - pubspec.yaml                                                  (dart pub add)
  - lib/core/services/<domain>/<package>_wrapper.dart            (created)
  - test/core/services/<domain>/<package>_wrapper_test.dart      (created — TDD RED→GREEN)
flutter test: PASS (<package>_wrapper_test.dart — all tests GREEN)
flutter analyze: 0 issues
Access: ref.watch(<pkg>Provider)
Wrapper method signatures (for D.0.1–D.0.5b test mocks):
  - <returnType> <methodName>(<params>)
```

---

## Error Cases

| Condition | Action |
|---|---|
| Wrapper already exists | Return `ALREADY_EXISTS`, no changes |
| `dart pub add` fails | Abort, return error to orchestrator |
| analyze still failing after fixes | Return `ANALYZE_FAILED: <issues>` — do not proceed |
| No suitable domain folder found | Use `lib/core/services/general/` or create an appropriate domain folder |

---

## Mandatory Next Step (post-creation)

After this agent completes, the orchestrator SHOULD invoke `app-class-to-solid-min` on the new wrapper only if the service needs Riverpod injection (category "Injectable service" per `MD/APP_PACKAGE_WRAPPER.md`). Pure utility wrappers do not need it.
