---
name: app-barrel
description: Orchestrates barrel_lib then barrel_file in sequence to create _[name].lib.dart and _[name].dart facade files for a Dart folder, centralizing imports and exposing a Custom[Name] class. Use when creating or updating barrel files for any folder under lib/.
---

Skill: barrel

Summary
Orchestrator that executes in sequence and completely the `barrel_lib` and `barrel_file` skills. All steps from both skills are mandatory.

Goal
- Execute in sequence ALL steps of `barrel_lib` (creates/updates `_[name].lib.dart`) and then ALL steps of `barrel_file` (creates/updates `_[name].dart` and centralizes imports), leaving the transformation logic in the specific skills.

Input parameters
- `directory` (string): relative path to the folder to process in the workspace.
- `name` (string): base name of the barrel; automatically derived from the last path segment if not explicitly provided.

Behavior — Phase 1: execute barrel_lib (all steps are mandatory)
1. Validate that `directory` exists and contains relevant public `.dart` files. Stop if there are no valid files.
2. Determine `name` as the last segment of `directory`.
3. Build the barrel filename: `_[name].lib.dart`.
4. List all public Dart files in the folder (exclude those starting with `_` and `*.g.dart`).
5. Collect all `import` directives from those files: deduplicate and sort (`dart:` first, then `package:`, then relative; alphabetically within each group).
6. Write `_[name].lib.dart` with the collected `import` statements followed by the `part 'file.dart';` entries sorted by name.
7. For each public file: remove its centralized `import` statements and add `part of '_[name].lib.dart';` at the beginning.
8. Search the entire repo for external imports pointing to files in the folder and replace them with a single import to the barrel `_[name].lib.dart` (using `package:` form or relative depending on the source). Save the complete list of modified paths.
9. Run `dart analyze` on the affected package. Fix any `import_of_non_library` errors or undefined references by changing external imports to the barrel and adjusting any other barrel that imports these files. Save all modified paths.
10. Generate barrel_lib summary: markdown table with modified files, centralized imports, and line count added/removed, plus the complete list of paths with updated imports (this list is mandatory for Phase 2).

Behavior — Phase 2: execute barrel_file (all steps are mandatory)
11. Take the `import list` from the complete path list generated in step 10.
12. Build the facade filename: `_[name].dart`.
13. Scan the folder and collect public Dart files (not starting with `_` and not `*.g.dart`).
14. In each public file in the folder: **mandatorily** replace all `static const` declarations with `final` (remove the `static` modifier and change `const` to `final`). This step converts class properties into instance properties, enabling chained access through the facade. Example: `static const String endpoint = '/api';` → `final String endpoint = '/api';`. Do not skip this step under any circumstances.
15. For each public file in `_[name].lib.dart`: extract the public class names and add them to the `Custom[Name]` class (PascalCase) as `static final` members. The facade class must never contain `static const`; always use `static final`. Example: `static final SecureCredentialStore secureCredentialStore = SecureCredentialStore();`.
16. Write `_[name].dart` with the following content in this exact order:
    a. Mandatory first line: `part of '_[name].lib.dart';` (relative path to the same directory, e.g., `part of '_functions.lib.dart';`).
    b. Then, the complete `Custom[Name]` class with all `static final` members.
    c. Do not add user-oriented comments or `// TODO`.
17. Update `_[name].lib.dart` to include `_[name].dart` as part of the library: add the line `part '_[name].dart';` (e.g., `part '_functions.dart';`) alongside other `part` declarations if it doesn't already exist. This action is mandatory.
18. Run `dart analyze` on the affected package. Fix `import_of_non_library` errors or undefined references.
19. Throughout the project, replace direct uses of the folder's public files with chained access through `Custom[Name]`. Example: given a folder `colors/`, access via `CustomColors.primaryColor`. Property or method access on the object is chained directly on the facade member.
20. Update imports throughout the workspace: start with files from the `import list` from step 10 and continue with any other file that still imports files from the folder directly, replacing each individual `import` directive with a single one pointing to `_[name].dart`.
21. Run `dart analyze` again. Fix any remaining errors.
22. Generate barrel_file summary: markdown table with columns `static final` classes created and file paths where they are used.

Behavior — Phase 3: global summary (mandatory)
23. Present consolidated summary: created files, modified files, lines added/removed, and ambiguous cases not automated (without inserting comments in the files).

Output
- `_[name].lib.dart` created/updated in the folder with centralized imports, `part` declarations for public files, and `part '_[name].dart';` for the facade file.
- `_[name].dart` created/updated in the folder with `part of '_[name].lib.dart';` as the first line and the `Custom[Name]` facade class.
- All public files in the folder modified with `part of '_[name].lib.dart';` and without centralized imports.
- Imports in the repo updated to use the barrel where appropriate.

Usage example
- `directory=lib/shared/colors, name=colors` → barrel executes all 23 steps in order. Result: `_colors.lib.dart`, `_colors.dart` with the `CustomColors` class, and all external files updated to import the barrel.
- **Note**: the `name` parameter can override automatic derivation from the last segment of `directory`. For example, `directory=lib/shared/colors, name=colors` → `_colors.lib.dart` / `_colors.dart` with the `CustomColors` class. Always verify existing files before assuming automatic derivation.
- **Note**: the `shared/jsons/` directory has been removed. The project no longer uses `CustomJsons` for mock data. Mock data now lives in per-feature `FakeDatasource` classes.

Considerations and safety
- Respect files starting with `_` and `*.g.dart`; do not convert them to `part`.
- **Do not convert to `part` files that already declare their own `part`** (for example, files annotated with `@riverpod` that contain `part '....g.dart';`). A `part` file cannot declare other `part` files. Instead, add them as `import` in `_[name].lib.dart`.
- Do not create automatic `.bak` backups.
- Do not use `export` in generated files.
- Do not generate user-oriented comments or `// TODO` in created or modified files.
- When a transformation is ambiguous, do not modify the code and record the decision in the summary (step 23).