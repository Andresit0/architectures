---
name: app-agent-cp-package
description: Creates a cp_<package>.dart wrapper in lib/shared/functions/ for a new pub package. Invoked by Spec-Local-Orchestrator Phase C repair when CpPackage audit fails. Never call directly — use via orchestrator task().
---

# App Agent: CP Package Wrapper Creator

## Purpose

Sub-agent delegated by the Spec-Local-Orchestrator when Phase-Gate detects a missing `cp_<package>.dart` wrapper. The orchestrator MUST NOT create wrappers inline — it delegates via `task()` to this agent.

## Input

The orchestrator passes:
- **package_name**: exact pub.dev package name (e.g. `url_launcher`)
- **feature_name**: the feature that requires this wrapper (for context/logging)
- **minimal_api**: brief description of what methods/functionality to expose

## Rules (non-negotiable)

1. **NEVER** add `import 'package:<pkg>/...'` inside `cp_<pkg>.dart`. The `part of` directive means the wrapper shares the scope of `_function.lib.dart` — the import goes there, not in the part file.
2. **Default values in constructors MUST be `const`** when the type supports it (e.g. `const Color(0xFF...)`, `const EdgeInsets.all(0)`).
3. **Run `flutter analyze lib/shared/functions/`** before returning. Zero issues required. **If analyze fails, fix all issues before proceeding — NEVER return with analyze errors.**
4. **STOP** if the wrapper already exists — do not overwrite. Report back to the orchestrator.
5. Apply SOLID interface pattern — **delegate to `app-class-to-solid-min`**:
   Read `.ai/skills/app-class-to-solid-min/SKILL.md` and follow it exactly for `cp_<package_name>.dart`.
   Concretely (sourced from that SKILL.md):
   a) In `cp_<pkg>.dart`, add `abstract class ICp<PkgName>` ABOVE `class Cp<PkgName>`. The interface declares only the public method signatures — no bodies.
   b) Add `implements ICp<PkgName>` to `Cp<PkgName>` and `@override` on every method.
   c) In `_function.dart`, change the static field type from `Cp<PkgName>` to `ICp<PkgName>`.
   d) Run `flutter analyze lib/shared/functions/` → 0 issues required before returning. Fix any issues before proceeding.
   Do NOT create a Riverpod provider for UI-only / pure-utility wrappers (fl_chart, lottie, logger, etc.). Only injectable services (dio, token, sharePlus) get a provider — check `MD/APP_PACKAGE_WRAPPER.md`.
6. **THE WRAPPER IS A THIN FACADE — NOT BUSINESS LOGIC.** The wrapper must only re-expose the package's own public API (types, constructors, methods). It MUST NOT contain any domain logic, widget-building code, chart configuration, layout, styling, or data transformation. All of that belongs in the feature's presentation layer (widgets). If you find yourself writing `LineChart(...)`, `HorizontalLine(...)`, or any feature-specific rendering code inside the wrapper, you are violating this rule. Stop and delete that code.
7. **NEVER invent types.** Only use types that actually exist in the package. Before writing any type name, verify it exists in the package's exported API. Common failure mode: inventing `ChartDataPoint`, `LineChartBarSpot` as a constructor method, etc.

---

## Execution Steps

### Step 1 — Guard: wrapper already exists?

Check `lib/shared/functions/cp_<package>.dart`.

```
glob: lib/shared/functions/cp_<package>.dart
```

- **EXISTS** → Stop. Return: `ALREADY_EXISTS: cp_<package>.dart found at <path>. No changes made.`
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

### Step 4 — Create cp_<package>.dart

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

Create `lib/shared/functions/cp_<package>.dart`:

```dart
part of '_function.lib.dart';

abstract class ICp<Pkg> {
  // Only methods the feature actually calls.
  // Each method delegates to the package — no logic here.
  // Example for url_launcher:
  //   Future<void> launch(String url);
}

class Cp<Pkg> implements ICp<Pkg> {
  // One-liner implementations that call the real package API.
  // Do NOT import the package here — it's already in _function.lib.dart.
  // Example:
  //   @override
  //   Future<void> launch(String url) => launchUrl(Uri.parse(url));
}
```

**Naming rules:**
- File: `cp_<package_name>.dart` (snake_case, matching pub package name)
- Abstract class: `ICp` + PascalCase of package (e.g. `ICpUrlLauncher`)
- Concrete class: `Cp` + PascalCase (e.g. `CpUrlLauncher`)

**Pattern reference** (`cp_go_router.dart`):
```dart
part of '_function.lib.dart';

abstract class ICpGoRouter {
  void go(String location, {Object? extra});
  void push(String location, {Object? extra});
}

class CpGoRouter implements ICpGoRouter {
  final GoRouter _router;
  CpGoRouter(this._router);

  @override
  void go(String location, {Object? extra}) => _router.go(location, extra: extra);

  @override
  void push(String location, {Object? extra}) => _router.push(location, extra: extra);
}
```

**For UI-only packages** (e.g. `fl_chart`, `lottie`, `cached_network_image`) where the widget IS the API:

**CRITICAL RULE: The wrapper is the SINGLE file that may import the package. If any feature code needs to import the package to construct arguments for the wrapper, the wrapper is too thin — it leaks the package's type system into the project.**

The wrapper must accept only simple types (`double`, `int`, `String`, `bool`, `Color`, `List`, `Map`, `Set`, and Flutter/dart: types) and construct the package's complex types internally.

```dart
// CORRECT — wrapper is self-contained, feature never imports the package
abstract class ICpFlChart {
  Widget lineChart({
    required List<double> values,
    List<String>? labels,
    Color? lineColor,
    Color? fillColor,
  });
}

class CpFlChart implements ICpFlChart {
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
class CpFlChart implements ICpFlChart {
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

### Step 5 — Register import in _function.lib.dart

Read `lib/shared/functions/_function.lib.dart`.

Add two lines in the correct locations:

**a) Import line** — add with the other `package:` imports:
```dart
import 'package:<package_name>/<package_name>.dart';
```
If the package uses a different main entry file, use the correct one (check pub.dev or package docs).

**b) Part directive** — add at the end of the `part` block:
```dart
part 'cp_<package>.dart';
```

**Do not reorder existing lines.** Append the import after the last `package:` import; append the part after the last `part` line.

---

### Step 6 — Expose in _function.dart

Read `lib/shared/functions/_function.dart`.

Add a static member inside `CustomFunction`:

```dart
static final I<CpPkg> <camelName> = Cp<Pkg>();
```

Example for `url_launcher`:
```dart
static final ICpUrlLauncher urlLauncher = CpUrlLauncher();
```

**Placement:** add after the last `static final` line before the closing `}`.

Consumer access: `CustomFunction.<camelName>.<method>()` — no import changes needed in feature files.

---

### Step 7 — Run flutter analyze (BLOCKING)

```bash
flutter analyze lib/shared/functions/
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

Re-run `flutter analyze lib/shared/functions/` after each fix.
**Do NOT proceed to Step 8 until the output is exactly: `No issues found!`**

---

### Step 8 — Save to Engram

```
mem_save(
  title: "Wrapper creado: cp_<package>",
  type: "decision",
  content: """
    **What**: Created cp_<package>.dart wrapper in shared/functions
    **Why**: Required by feature '<feature_name>' — detected missing by Phase-Gate
    **Where**: lib/shared/functions/cp_<package>.dart, _function.lib.dart, _function.dart
    **Learned**: <any gotchas found during creation, or omit if none>
  """
)
```

---

### Step 9 — Return confirmation

Return a structured summary to the orchestrator:

```
CP_PACKAGE_DONE

Package   : <package_name>
Feature   : <feature_name>
Files modified:
  - pubspec.yaml                                                  (dart pub add)
  - lib/shared/functions/cp_<package>.dart                       (created)
  - lib/shared/functions/_function.lib.dart                      (import + part added)
  - lib/shared/functions/_function.dart                          (static member added)
  - test/shared/functions/cp_<package>_test.dart                 (created — TDD RED→GREEN)
flutter test: PASS (cp_<package>_test.dart — all tests GREEN)
flutter analyze: 0 issues
Access: CustomFunction.<camelName>.<method>()
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
| Package has no single entry-point file | Check pub.dev docs, use correct import path, document in Engram |

---

## Mandatory Next Step (post-creation)

After this agent completes, the orchestrator SHOULD invoke `app-class-to-solid-min` on the new wrapper only if the service needs Riverpod injection (category "Injectable service" per `MD/APP_PACKAGE_WRAPPER.md`). Pure utility wrappers do not need it.
