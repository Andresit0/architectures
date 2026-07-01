---
name: app-spec-definition
description: Guides users through collaboratively refining a user story into a complete, agreed-upon specification. Invoked by the Spec-Local orchestrator as Phase A — do NOT call directly in response to feature requests. Call directly only when the user explicitly says "run app-spec-definition directly" or "load skill app-spec-definition" (e.g., to revise an already-written spec in isolation).
---

# Spec Definition

## Purpose

Transform a rough user story into a fully defined specification by surfacing hidden assumptions and getting explicit answers from the user — collaboratively, one question at a time.

## Workflow

### Step 1 — Receive the user story

Wait for the user to provide a user story in any form:
- Formal: "As a [role], I want [goal] so that [reason]"
- Descriptive: "Users should be able to reset their password"
- Rough: "Add a dashboard with sales metrics"

If no user story has been given yet, ask for it before proceeding.

### Step 2 — Fill in the blanks

Analyze the user story and produce a numbered list of **non-technical, functional assumptions** you're making to interpret it. These are the implicit decisions baked into any reasonable reading of the story — things about scope, behavior, UX flows, business rules, edge cases, user roles, permissions, data, integrations, error handling, and success criteria.

**Include:** what the feature does, who can use it, when it applies, what happens in error cases, what data is involved, what triggers the behavior.

**Exclude:** technology choices, architecture, frameworks, infrastructure, implementation details, code structure. Stay firmly on the *what*, never on the *how*.

Aim for 8–15 assumptions. Too few leaves gaps; too many becomes overwhelming.

**Output format:**
```
Based on your user story, here are the assumptions I've made to define the spec:

1. [Functional or behavioral assumption]
2. [Business rule assumption]
3. [User role / permission assumption]
...

Which of these don't fit your vision? Give me the numbers and I'll ask you about them one by one.
```

### Step 3 — Collect the user's objections

The user replies with the numbers of assumptions they want to change (e.g., `2, 5, 7` or `3 and 8`).

Internally track:
- `total_to_refine` = how many numbers were given
- `current_question` = starts at 1
- A queue of the flagged assumptions, in the order given

### Step 4 — Refine each assumption, one by one

For each flagged assumption, ask a single focused question with **exactly 4 concrete options** plus a 5th "Other" option.

**Message format:**
```
Progress: [████████░░] Question 2 of 5

**Assumption #3:** [restate the original assumption clearly]

How should this actually work?

1. [Plausible alternative A]
2. [Plausible alternative B]
3. [Plausible alternative C]
4. [Plausible alternative D]
5. Other — tell me what you have in mind

Reply with a number (1–5).
```

**Progress bar rules:**
- 10 block total width using `█` (filled) and `░` (empty)
- Filled blocks = `floor((current_question - 1) / total_to_refine * 10)`
- Always show "Question X of Y" alongside the bar

| Example | Bar |
|---------|-----|
| Question 1 of 5 | `[░░░░░░░░░░]` |
| Question 2 of 5 | `[██░░░░░░░░]` |
| Question 3 of 5 | `[████░░░░░░]` |
| Question 4 of 5 | `[██████░░░░]` |
| Question 5 of 5 | `[████████░░]` |

**Option rules:**
- Options 1–4 must be distinct, concrete, and cover the realistic range of plausible answers for that specific assumption — not generic labels like "Option A" or "Yes/No"
- Option 5 is always: `Other — tell me what you have in mind`
- If the user picks 5, follow up with: `What should it be instead?` and accept their free-form answer as the new definition

### Step 5 — Apply and continue

After receiving the user's answer:
- Internally update the assumption with the new definition
- Move immediately to the next flagged assumption — no summaries, no restating all the changes, no filler

### Step 6 — Signal readiness

Once all flagged assumptions have been refined, say:

```
I've incorporated all your clarifications. I'm ready to create the specification whenever you say the word.
```

Then wait. If the user immediately asks for the spec, generate it. If the context suggests they want to review first, let them lead.

### Step 7 — Delegate artifact writing to spec-definer

When the user confirms they want the spec created, **do not write files directly from this skill**. Instead, hand off to the `spec-definer` agent (`.ai/skills/app-agent-spec-definer/SKILL.md`) which handles:

- Feature name confirmation (snake_case)
- Generation of all six artifact files (spec.md, bdd.feature, tests.md, contracts.md, domain.md, tasks.md)
- Writing the `lib/features/<feature_name>/spec/` folder

Pass the full set of confirmed assumptions to the spec-definer as the input for Phase 3 (artifact generation). Do not generate or write any spec files from within this skill.

---

## Principles to keep in mind

**One question at a time.** Never ask about two assumptions in the same message. The point is to reduce cognitive load, not batch it back.

**Concrete options only.** "Option A" or "the user decides" are not useful options. Every option should read like a real product decision. If you can't think of 4 distinct plausible answers, think harder — they're always there.

**Functional, not technical.** If an option sounds like it belongs in a sprint ticket's "implementation notes" section, remove it. Every assumption and every option must be about behavior and business logic.

**Trust the user's domain knowledge.** If they pick "Other", accept their answer without pushback. They know their context better than you do.

**Keep momentum.** The progress bar + the question is the entire message. No preamble, no "Great choice!", no summaries between questions. Clarity and pace matter.
