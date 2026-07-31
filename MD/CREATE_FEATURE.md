# CREATE_FEATURE — How to create a new feature end-to-end

This document explains how to use the **app-spec-definer** agent and then execute the full SDD → BDD → TDD → implementation pipeline. A complete worked example is provided using the `medical_appointments` feature.

---

## What is app-spec-definer?

app-spec-definer is an opencode skill at `.ai/skills/app-spec-definer/SKILL.md`. It transforms a feature idea into a complete specification package before any Dart code is written.

**When to use it:** every time a new feature is started — no exceptions.

**What it produces:**

| File | Content |
|---|---|
| `spec.md` | SDD functional specification (YAML) |
| `bdd.feature` | BDD Gherkin scenarios |
| `tests.md` | TDD test plan (unit + widget, YAML) |
| `contracts.md` | API endpoint contracts (YAML) |
| `domain.md` | Entities, state, interfaces, usecases (YAML) |
| `tasks.md` | Implementation task checklist |

Files are written to `lib/features/<feature_name>/spec/`.

If you provide a JSON sample, app-spec-definer also:
- Creates `lib/features/<feature_name>/infrastructure/datasources/fake_<feature_name>_datasource.dart`
  with hardcoded entity constructors (the old `CustomJsons`/`_jsons.lib.dart` pattern has been removed)

---

## How to invoke app-spec-definer in opencode

1. Open opencode in your terminal inside the project root
2. Press `ctrl+p` → select **app-spec-definer** from the agent list
3. Describe the feature you want to build and paste any JSON data you have

The agent will:
1. Generate 8–15 functional assumptions from your description
2. Ask you to flag any that don't fit your vision
3. Refine each flagged assumption one at a time
4. Confirm the feature folder name
5. Write the JSON file (if provided) and all six spec artifacts

---