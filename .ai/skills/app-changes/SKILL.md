---
name: app-changes
description: Returns a structured summary table of all current project changes with two columns (path and changes). Runs git status, git diff, and git log to identify modified, created, or deleted files and describes each change concisely. Use this skill whenever you need a structured overview of what changed before committing, documenting, or updating MD files. Trigger on phrases like "what changed", "show changes", "project changes", "get changes", "summarize changes", or any time a structured diff summary is needed.
model: github-copilot/gpt-5-mini
temperature: 0.1
---

# app_changes

Produces a structured two-column Markdown table of all current project changes by analyzing the git working tree.

## Purpose

Use this skill whenever you need a clear, structured view of what has changed in the project before committing, documenting, or reporting. The output is always a Markdown table with exactly two columns: **Path** and **Changes**.

---

## Steps

### 1. Run all four git commands

Execute these commands in order to gather the full picture of what has changed:

```bash
git status --short
git diff --stat
git diff
git log --oneline -10
```

### 2. Interpret each command's output

| Command | What to extract |
|---------|----------------|
| `git status --short` | Full list of changed files with their status codes: `M` (modified), `A` (added/staged), `??` (untracked/new), `D` (deleted), `R` (renamed) |
| `git diff --stat` | Confirmation of which tracked files have content changes and the scale of each change |
| `git diff` | The actual content of each change — use this to write a meaningful one-line description of *what* changed (not just *that* it changed) |
| `git log --oneline -10` | Recent commit history — use as context to understand intent, feature area, and naming conventions |

### 3. Write a concise description for each changed file

For each file identified, produce a single-sentence description focused on:
- What was added, removed, or modified (functionally, not just line counts)
- The purpose or impact of the change (e.g., "Added `LoginScreen` widget", "Removed deprecated `fetchUser` call", "Updated barrel exports to include `AuthNotifier`")
- If a file was deleted, write: `File deleted`
- If a file was newly created, prefix with: `File created — ` followed by a brief description
- If a file was renamed, prefix with: `Renamed from <old_path>` — then add ` — ` and a brief description of any content changes if the diff also shows edits, otherwise stop after the old path

**Detecting renames from `git status --short`:**
`git status --short` shows renames as:
```
R  old/path/file.dart -> new/path/file.dart
```
Always use the **new path** as the `Path` column value. The old path goes inside the `Changes` description. If `git diff` shows that the renamed file also has content changes beyond the move, describe them after the rename note.

---

## Output format

ALWAYS output a single Markdown table with **exactly** these two columns. Output nothing else — no headers, no prose, no preamble, no summary paragraph.

```
| Path | Changes |
|------|---------|
| path/to/new_file.ts | File created — brief description of purpose |
| path/to/file.dart | Brief description of what changed |
| new/path/renamed.dart | Renamed from old/path/renamed.dart |
| new/path/renamed_and_edited.dart | Renamed from old/path/file.dart — also updated X to use Y |
| path/to/deleted.md | File deleted |
```

### Sorting rules

1. Created files (`??`, `A`) first
2. Modified files (`M`) second
3. Renamed files (`R`) third
4. Deleted files (`D`) last
5. Within each group, sort alphabetically by path

### Edge case

If there are no changes at all, output:

```
| Path | Changes |
|------|---------|
| (none) | No changes detected in the working tree |
```

---

## Quality rules

- `Path`: always the **new** full relative path from the project root (e.g., `lib/features/auth/presentation/login_screen.dart`)
- `Changes`: one sentence, present tense, no trailing period
- Never output more than one row per file
- Never include binary files or lock files (`pubspec.lock`, `package-lock.json`) unless they are the only change
- For renamed files: `Path` = new path; `Changes` = `Renamed from <old_path>`, optionally followed by ` — <content change description>` if the file was also edited
- Never create two separate rows for a rename (one for the old path deleted + one for the new path created) — always collapse them into a single `R` row using the new path
