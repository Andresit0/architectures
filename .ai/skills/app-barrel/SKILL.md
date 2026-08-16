---
name: app-barrel
description: Creates or updates a pure-export barrel `_[name].lib.dart` for a Dart folder, centralizing imports via `export` lines (no `part`, no `library;`; optional standalone facade). Use when creating or updating barrel files for any folder under lib/.
---

# App-Barrel

## Summary
Creates/updates the `_[name].lib.dart` **pure-export barrel** of a folder: one `export '<file>.dart';` per public file, sorted. The folder's files stay **standalone** with their own imports — they are NOT converted to `part` and the barrel does NOT declare `library;`.

## Input parameters
- `directory` (string): relative path to the folder to process in the workspace.
- `name` (string): base name of the barrel; automatically derived from the last path segment if not explicitly provided.

## Behavior
1. Validate that `directory` exists and contains relevant public `.dart` files. Stop if there are no valid files.
2. Determine `name` as the last segment of `directory`.
3. Build the barrel filename: `_[name].lib.dart`.
4. List all public Dart files in the folder (exclude those starting with `_` and `*.g.dart` / `*.freezed.dart`).
5. Write `_[name].lib.dart` with one `export '<file>.dart';` per public file, sorted alphabetically. Do NOT add `library;` and do NOT add `part` directives.
6. Run `dart analyze` on the affected package. Fix any `import_of_non_library` errors by pointing external imports to the barrel.
7. Optionally update external imports in the repo to use the barrel (single import to `_[name].lib.dart`).
8. Generate summary: markdown table with the barrel path and the list of exported files.

## Output
- `_[name].lib.dart` created/updated in the folder with sorted `export` lines.
- Folder files remain standalone (own imports). NO `part of`, NO `library;`, NO facade generation.

## Usage example
- `directory=lib/shared/error, name=error` → `_error.lib.dart` with `export 'app_error.dart';`, `export 'result.dart';`, etc.

## Considerations and safety
- **EXCEPTION — `presentation/widgets/` folders are NOT barrelled.** Widget files are standalone with explicit imports and there is NO `_widgets.lib.dart` barrel and NO `Custom[Name]Widgets` facade. Do not run this skill on a `presentation/widgets/` folder.
- Respect files starting with `_` and `*.g.dart` / `*.freezed.dart`; never export them.
- **Do not add `library;` or `part`** — the barrel convention is pure-export (enforced by CI in `test/architecture/dependency_rules_test.dart`).
- Optional facades (`Custom[Name]`) are standalone classes with their own imports, exported by the barrel (e.g. `CustomInterceptors`); they are NOT `part of` the barrel.
- Do not create automatic `.bak` backups.
- Do not generate user-oriented comments or `// TODO` in created or modified files.
- When a transformation is ambiguous, do not modify the code and record the decision in the summary.
