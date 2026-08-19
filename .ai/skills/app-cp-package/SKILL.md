---
name: app-cp-package
description: Convention for adding a new Dart/Flutter package dependency and creating a local wrapper (<package>_wrapper.dart) in lib/core/services/<domain>/. Use when the user requests using a new package that doesn't yet have a wrapper in the project.
---

Skill: app-cp-package

Description
This skill defines the convention and steps the assistant must follow when the user requests to use a Dart/Flutter package and the corresponding wrapper does not exist in `lib/core/services/<domain>/`.

Goal
Automate the incorporation of new dependencies in `pubspec.yaml` and create a wrapper inside `lib/core/services/<domain>/` with the `Wrapper` suffix to allow easy future replacements.

Expected behavior
1. Detection: If the user requests to use a new package (e.g., `share_plus`) and it does not have a wrapper in `lib/core/services/<domain>/`, perform the following steps.
   - Identify: correct package name (e.g., `share_plus`).
   - Identify: the appropriate domain folder under `lib/core/services/` (e.g., `device`, `storage`, `crypto`, `auth`, `logging`, `network`, `database`).
2. Add the dependency if it doesn't exist:
   - Preference: use `dart pub add <package>` from the project root if the environment allows it.
   - Alternative: edit `pubspec.yaml` adding the entry in `dependencies:` with the version indicated by the user (or `any` if not specified).
2b. Write wrapper test FIRST (TDD — RED before GREEN):
   - Create `test/core/services/<domain>/<package>_wrapper_test.dart`.
   - Test only the wrapper's public API surface — what `<PkgName>Wrapper` exposes.
   - For UI-only packages: test that the factory method returns a `Widget` given valid input.
   - For service packages: test the method returns the expected type given a mock input.
    - Run `flutter test test/core/services/<domain>/<package>_wrapper_test.dart` from the project root — EXPECTED: compile error or failure (wrapper doesn't exist yet). Confirm RED before proceeding.
3. Create local wrapper (GREEN):
   - Create folder: `lib/core/services/<domain>/` if it doesn't exist.
   - Add a file named `<package>_wrapper.dart` (e.g., `share_plus_wrapper.dart`). Note: the filename must use the `_wrapper` suffix after the package name.
    - The wrapper must expose or adapt the minimal API the project will use. Rules:
      - A specific method must be created for each functionality requested by the user, inside a class with the `Wrapper` suffix (example: `SharePlusWrapper`). The class doesn't need an interface at this step; the interface is added in the next step with `class_to_solid_min`.
      - **THE WRAPPER IS THE SINGLE BOUNDARY.** No code outside `lib/core/services/<domain>/` may ever import the package. If a feature needs to construct a type from the package to call the wrapper, the wrapper is **too thin** — enhance it to accept simple types (primitives, `List`, `Map`, `Color`, `String`, `double`, etc.) and construct the package's types internally.
      - **For UI-only packages** (e.g. `fl_chart`, `lottie`): the wrapper exposes methods that accept simple data (lists of values, labels, colors) and returns the widget — the feature never imports the package. Example: `Widget lineChart({required List<double> values, List<String>? labels, Color? lineColor}) => ...` internally building `LineChartData`. Feature-specific *business* configuration (axis labels, color mapping from domain entities) stays in the presentation widget — but the *type construction* from simple values lives in the wrapper.
      - **NEVER invent types or domain models** inside the wrapper. Use only: primitives, `List`, `Map`, `Set`, `Color`, `String`, `double`, `int`, `bool`, and types from `dart:` or `package:flutter/`. The wrapper constructs the package's own types from these simple inputs — it does NOT create new data classes.
      - **Run `flutter analyze lib/core/services/<domain>/` after writing** and fix all issues before returning. Zero issues is mandatory — do not return with analyze errors.

     - For example if the user asks to use `share_plus` to share PDFs, the wrapper could be:

     ```dart
     class SharePlusWrapper {
       Future<void> pdf(
         String encounterId,
         List<int> bytes,
       ) async {
         final dir = await getTemporaryDirectory();
         final file = File('${dir.path}/resultado_$encounterId.pdf');
         await file.writeAsBytes(bytes);
         await Share.shareXFiles([
           XFile(
             file.path,
             mimeType: 'application/pdf',
             name: 'resultado_$encounterId.pdf',
           ),
         ], subject: 'Resultado PDF');
       }
     }
     ```
     - The wrapper file has its own `import` statements for the packages it wraps. It is a standalone file (not a `part of`).

4. Consumers access the wrapper via Riverpod provider:
   - The wrapper file (`<package>_wrapper.dart`) is a standalone file in `lib/core/services/<domain>/`.
   - Consumer files access it via Riverpod provider: `ref.watch(<pkg>Provider)` imported from its `core/` source file (no app-level barrel).

5. Notify the user of the changes made:
   - Show the lines added to `pubspec.yaml` and run `dart pub get` from the project root.

Naming and replacement policy
- The wrapper must be named `<package>_wrapper.dart` in `lib/core/services/<domain>/`.
- In project code, always use the wrapper (`<PkgName>Wrapper`) instead of the direct package, to allow changing the implementation simply by editing the wrapper.

Considerations and limitations
- Do not version dependencies with insecure versions without asking (if the user doesn't specify, use `any` or the last known stable version and notify).
- When the package API is large, initially create a wrapper with only the necessary entries (do not re-export everything without control).

Usage example (user request)
- User: "Use the `url_launcher` package to open links." -> The assistant:
  1. Adds `url_launcher` to `pubspec.yaml` or runs `dart pub add url_launcher`.
  2. Creates `lib/core/services/device/url_launcher_wrapper.dart` with the `UrlLauncherWrapper` class (standalone file, not `part of`).
  3. Consumer files access the wrapper via Riverpod provider: `ref.watch(urlLauncherProvider)`.
  4. Returns a summary of the changes and the suggested command to get dependencies.

Mandatory next step
After executing this skill, always apply the `class_to_solid_min` skill (SKILL.md at `.ai/skills/app-class-to-solid-min/SKILL.md`) to:
- Add the abstract interface `I<Package>` to the wrapper.
- Create the Riverpod provider in `lib/core/services/<domain>/<name>_provider.dart` (Rule 20 — DI en archivos `*_providers.dart` separados de la implementación, sin barrel de app) if the service needs injection (category "Injectable service").

---

## Memory Protocol (Engram)

### After completion — mandatory

```
mem_save(
  title: "Wrapper created: <package>_wrapper",
  type: "decision",
  content: "**What**: Created local wrapper <package>_wrapper.dart for the <package> pub package. **Why**: <user request or feature need>. **Where**: lib/core/services/<domain>/<package>_wrapper.dart. **Learned**: <any gotchas with the package API or part-of wiring>"
)
```