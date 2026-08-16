# AI Artifact Creation Guide

Guide to creating skills, agents, commands, orchestrators, prompts, and templates in the `.ai/` centralized structure.

---

## Directory Structure

```
.ai/
├── skills/           ← Skills AND agents (unified location)
│   ├── app-*             ← App skills (prefijo app-)
│   └── app-agent-*       ← App agents (prefijo app-agent-)
├── commands/         ← CLI command scripts for AI
├── orchestrators/    ← Workflow orchestrators (multi-phase flows)
├── memory/          ← Persistent memory (Engram/Openspec)
├── prompts/         ← Reusable prompt templates
├── specs/          ← SDD/OpenSpec specification artifacts
└── templates/      ← File/structure templates
```

---

## 1. Agents

**What**: Define how an AI agent behaves, its responsibilities, and workflow.

**Location**: `.ai/skills/`

**Naming**: `app-agent-{name-in-lowercase}/SKILL.md` (con prefijo app-agent-)

**Structure**:
```markdown
---
name: app-agent-name
description: One-line summary of what this agent does
trigger: Phrases or commands that activate this agent
---

# Agent Name

## Role
[What this agent does]

## Responsibilities
- [Responsibility 1]
- [Responsibility 2]

## Context
[What information this agent receives/uses]

## Output
[What this agent produces]

## Constraints
[What this agent must/must not do]
```

**Example**: `.ai/skills/app-agent-update-md/SKILL.md`

---

## 2. Skills

**What**: Specialized instructions for specific tasks (Dart patterns, Flutter widgets, etc.).

**Location**: `.ai/skills/`

**Naming**: `app-{skill-name}/SKILL.md` (con prefijo app-)

**Structure**:
```markdown
---
name: app-skill-name
description: What this skill does
trigger: When to invoke this skill
---

# Skill Name

## Overview
[What this skill covers]

## When to Use
[Specific trigger phrases or contexts]

## Guidelines
[Detailed instructions, patterns, examples]

## Examples
[Code examples, before/after, etc.]

## References
[Links to related skills, docs, or files]
```

**Example**: `.ai/skills/app-class-to-solid/SKILL.md`

---

## 3. Commands

**What**: Scripts/steps that AI executes as a command.

**Location**: `.ai/commands/`

**Naming**: `{command-name}.md` (kebab-case)

> **Language**: All user-facing text and prompts inside a command must be in **English** (enterprise convention). Bilingual affirmative-answer lists may be kept for developer convenience.

**Structure**:
```markdown
# Command Name

## Description
[What this command does]

## Usage
[When/how to invoke this command]

## Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Verification
[How to verify the command succeeded]

## Examples
[Example usage or output]
```

**Example**: `.ai/commands/super-commit.md`

---

## 4. Orchestrators

**What**: Multi-phase workflows that coordinate agents and skills.

**Location**: `.ai/orchestrators/`

**Naming**: `{Orchestrator-Name}.md` (kebab-case, capitalize)

**Structure**:
```markdown
---
name: Orchestrator Name
description: Multi-phase workflow orchestrator
phases: [list of phases]
---

# Orchestrator Name

## Overview
[What this orchestrator coordinates]

## Phase Flow
```
[Phase 1] → [Phase 2] → [Phase 3] → ...
```

## Phase Descriptions

### Phase 1: [Name]
- **Tool**: [agent/skill used]
- **Input**: [what it receives]
- **Output**: [what it produces]
- **Next**: [what triggers the next phase]

### Phase 2: [Name]
[... same structure ...]

## Completion Criteria
[What signals the orchestrator is done]

## Edge Cases
[How to handle errors or special conditions]
```

**Example**: `.ai/orchestrators/Spec-Local-Orchestrator.md`

---

## 5. Prompts

**What**: Reusable prompt templates for consistent AI interactions.

**Location**: `.ai/prompts/`

**Naming**: `{prompt-name}.md` (kebab-case, descriptive)

**Structure**:
```markdown
# Prompt Name

## Context
[Background information for the prompt]

## Task
[What the AI should do]

## Constraints
[Boundaries, rules, or limitations]

## Output Format
[How the response should be structured]

## Examples
[Sample inputs/outputs]
```

---

## 6. Specs (SDD/OpenSpec)

**What**: Specification artifacts for software design documents.

**Location**: `.ai/specs/`

**Naming**: `{feature-name}/` folder with multiple `.md` files

**Typical Files**:
- `spec.md` — Feature specification
- `domain.md` — Domain model
- `contracts.md` — Interface contracts
- `bdd.feature` — BDD scenarios
- `tests.md` — Test plan
- `tasks.md` — Implementation tasks

---

## 7. Templates

**What**: File templates for consistent structure.

**Location**: `.ai/templates/`

**Naming**: `{template-type}.md` or `{type}.{ext}.template`

---

## Quick Reference: When to Create What

| Need | Create in |
|------|-----------|
| Define AI behavior for a task | `.ai/skills/app-agent-*/SKILL.md` |
| Provide instructions for a specific skill | `.ai/skills/app-*/SKILL.md` |
| Script a sequence of steps | `.ai/commands/` |
| Coordinate multi-phase workflows | `.ai/orchestrators/` |
| Reusable prompt patterns | `.ai/prompts/` |
| Feature specifications | `.ai/specs/` |
| File structure templates | `.ai/templates/` |

---

## Tool Integration

| Tool | Config Location | Reads |
|------|-----------------|-------|
| **OpenCode** | `.opencode/config.json` | `.ai/skills/`, `.ai/commands/`, `.ai/orchestrators/` |
| **Copilot** | `.github/copilot-instructions.md` | References `.ai/` |
| **Gentle AI** | `.ai/skills/` directly | All skills |
| **Cursor** | `.cursor/.rules.md` | References `.ai/` |

---

## Creation Checklist

- [ ] Choose correct directory
- [ ] Follow naming convention (kebab-case)
- [ ] Add frontmatter with name, description, trigger
- [ ] Include examples
- [ ] Add to skill-registry if it's a skill
- [ ] Test with relevant AI tool