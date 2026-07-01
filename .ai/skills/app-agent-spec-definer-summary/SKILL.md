---
name: app-agent-spec-definer-summary
description: Creates the 6 specification files in lib/features/<feature>/spec/ and returns ONLY the summary table the orchestrator needs.
---

# Skill: app-agent-spec-definer-summary

Purpose
---------
Create the specification package (6 files) for a new feature and, as the only output of execution, return a concise table (markdown) with the information the main orchestrator needs to decide the next steps.

Motivation
----------
The main orchestrator should only receive relevant data (paths and a brief summary per file) to keep context small and avoid filtering irrelevant information.

Input
-------
- feature_name (snake_case) — destination feature name (e.g., lab_results_chart)
- spec_content (optional) — map/document with the exact content to write for each of the 6 files. If omitted, the agent generates templates based on the repo conventions.

Output (strict)
-----------------
The only content the skill returns to the caller must be a markdown table with exactly three columns:

| file | path | summary |
|------|------|---------|

- `file`: file name (spec.md, bdd.feature, tests.md, contracts.md, domain.md, tasks.md)
- `path`: full path written in the repo (relative to root)
- `summary`: one line (max 120 characters) describing the file's purpose (no more)

Do not return file contents or any other metadata (no dates, no diffs, no logs). If the agent writes the files, it must return them in that table and nothing more.

Effect on disk
----------------
Writes (or overwrites) the following files in `lib/features/<feature_name>/spec/`:

- spec.md
- bdd.feature
- tests.md
- contracts.md
- domain.md
- tasks.md

Each file must follow the template and conventions defined in MD/ and AGENTS.md (names, YAML/Gherkin structures, mock JSON paths). If `spec_content` is present use it as-is; if not, generate conservative templates.

Mandatory rules
-------------------
1. Do not print or return the full content of the files.
2. The only output is the described markdown table.
3. Confirm the folder `lib/features/<feature_name>/spec/` exists or create it.
4. Respect project naming and path conventions.

Example of expected output
-------------------------

| file | path | summary |
|------|------|---------|
| spec.md | lib/features/foo/spec/spec.md | Functional SDD and business rules (YAML) |
| bdd.feature | lib/features/foo/spec/bdd.feature | Gherkin scenarios describing the flows |

Notes for the orchestrator
------------------------
- The calling orchestrator will receive a single string (the table). Use this for verification and to decide the next delegation.
- If the agent finds a conflict (already existing files) it must overwrite them — but must not return diffs, only the final table.

Base directory for this skill: file://{repo_root}/.ai/skills/app-agent-spec-definer-summary
