---
name: app-cp-package
description: Convention for adding a new Dart/Flutter package dependency and creating a local wrapper (cp_<package>.dart) in lib/shared/functions. Use when the user requests using a new package that doesn't yet have a wrapper in lib/shared/functions.
---

Skill: cp_package

Description
This skill defines the convention and steps the assistant must follow when the user requests to use a Dart/Flutter package and the corresponding function does not exist in `lib/shared/functions`.

Goal
Automate the incorporation of new dependencies in `pubspec.yaml` and create an adapted copy (wrapper) inside `lib/shared/functions` with the `Cp` prefix to allow easy future replacements.

Expected behavior
1. Detection: If the user requests to use a new package (e.g., `share plus`) and it is not being used within `lib/shared/functions`, perform the following steps.
   - Identify: correct package name (e.g., `share_plus`).
2. Add the dependency if it doesn't exist:
   - Preference: use `dart pub add <package>` from the project root if the environment allows it.
   - Alternative: edit `pubspec.yaml` adding the entry in `dependencies:` with the version indicated by the user (or `any` if not specified).
2b. Write wrapper test FIRST (TDD — RED before GREEN):
   - Create `test/shared/functions/cp_<package>_test.dart`.
   - Test only the wrapper's public API surface — what `Cp<Package>` exposes.
   - For UI-only packages: test that the factory method returns a `Widget` given valid input.
   - For service packages: test the method returns the expected type given a mock input.
    - Run `flutter test test/shared/functions/cp_<package>_test.dart` from the project root — EXPECTED: compile error or failure (wrapper doesn't exist yet). Confirm RED before proceeding.
3. Create local wrapper (GREEN):
   - Create folder: `lib/shared/functions/` if it doesn't exist.
   - Add a file named `cp_<package>.dart` (e.g., `cp_share_plus.dart`). Note: the filename must use the `cp_` prefix followed by the package name to avoid conflicts.
    - The wrapper must expose or adapt the minimal API the project will use. Rules:
      - A specific function must be created for each functionality requested by the user, inside a class with the `Cp` prefix (example: `CpSharePlus`). The class doesn't need an interface at this step; the interface is added in the next step with `class_to_solid_min`.
      - **THE WRAPPER IS THE SINGLE BOUNDARY.** No code outside `_function.lib.dart` may ever import the package. If a feature needs to construct a type from the package to call the wrapper, the wrapper is **too thin** — enhance it to accept simple types (primitives, `List`, `Map`, `Color`, `String`, `double`, etc.) and construct the package's types internally.
      - **For UI-only packages** (e.g. `fl_chart`, `lottie`): the wrapper exposes methods that accept simple data (lists of values, labels, colors) and returns the widget — the feature never imports the package. Example: `Widget lineChart({required List<double> values, List<String>? labels, Color? lineColor}) => ...` internally building `LineChartData`. Feature-specific *business* configuration (axis labels, color mapping from domain entities) stays in the presentation widget — but the *type construction* from simple values lives in the wrapper.
      - **NEVER invent types or domain models** inside the wrapper. Use only: primitives, `List`, `Map`, `Set`, `Color`, `String`, `double`, `int`, `bool`, and types from `dart:` or `package:flutter/`. The wrapper constructs the package's own types from these simple inputs — it does NOT create new data classes.
      - **Run `flutter analyze lib/shared/functions/` after writing** and fix all issues before returning. Zero issues is mandatory — do not return with analyze errors.

     - For example if the user asks to use `share_plus` to share PDFs, the wrapper could be:

     ```dart
     part of '_function.lib.dart';

     class CpSharePlus {
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
     - Verify that the imports and the `part` necessary for the wrapper are included within the `lib/shared/functions/_function.lib.dart` file, for example

     ```dart
     import 'dart:io';
     import 'package:flutter/material.dart';
     import 'package:path_provider/path_provider.dart';
     import 'package:share_plus/share_plus.dart';

     part 'cp_share_plus.dart';
     ```

     - Verify that the function is available through a centralized import: `lib/shared/functions/_function.dart` to avoid multiple imports in consumer files. For example:

     ```dart
     static final CpSharePlus sharePlus = CpSharePlus();
     ```

4. Consumers do not need import changes:
   - The wrapper file (`cp_<package>.dart`) is declared as `part of '_function.lib.dart'` and therefore **cannot be imported directly**. Any file that already imports `_function.lib.dart` (or `_function.dart`) automatically has access to the new wrapper.
   - All access goes through `CustomFunction.<name>` — no additional import changes are required in consumer files.

5. Notify the user of the changes made:
   - Show the lines added to `pubspec.yaml` and run `dart pub get` from the project root.

Naming and replacement policy
- The wrapper must be named `cp_<package>.dart` in `lib/shared/functions/`.
- In project code, always use the wrapper (`Cp<Package>`) instead of the direct package, to allow changing the implementation simply by editing the wrapper.

Considerations and limitations
- Do not version dependencies with insecure versions without asking (if the user doesn't specify, use `any` or the last known stable version and notify).
- When the package API is large, initially create a wrapper with only the necessary entries (do not re-export everything without control).

Usage example (user request)
- User: "Use the `url_launcher` package to open links." -> The assistant:
  1. Adds `url_launcher` to `pubspec.yaml` or runs `dart pub add url_launcher`.
  2. Creates `lib/shared/functions/cp_url_launcher.dart` with `part of '_function.lib.dart';` and the `CpUrlLauncher` class with the minimal API.
  3. Registers the package import and `part 'cp_url_launcher.dart';` in `_function.lib.dart`, and exposes the wrapper in `_function.dart` as `static final CpUrlLauncher urlLauncher = CpUrlLauncher();`. Consumers access via `CustomFunction.urlLauncher.xxx` — no import changes required in consumer files.
  4. Returns a summary of the changes and the suggested command to get dependencies.

Mandatory next step
After executing this skill, always apply the `class_to_solid_min` skill (SKILL.md at `.ai/skills/app-class-to-solid-min/SKILL.md`) to:
- Add the abstract interface `I<Package>` to the wrapper.
- Update the `CustomFunction` member to have the interface type (`I<Package>`), not the concrete class.
- Create the Riverpod provider in `shared/providers/<name>_provider.dart` if the service needs injection (category "Injectable service").

---

## Memory Protocol (Engram)

### After completion — mandatory

```
mem_save(
  title: "Wrapper created: cp_<package>",
  type: "decision",
  content: "**What**: Created local wrapper cp_<package>.dart for the <package> pub package. **Why**: <user request or feature need>. **Where**: lib/shared/functions/cp_<package>.dart, lib/shared/functions/_function.lib.dart, lib/shared/functions/_function.dart. **Learned**: <any gotchas with the package API or part-of wiring>"
)
```