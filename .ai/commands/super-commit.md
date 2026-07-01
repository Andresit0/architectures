# Build Professional Commit History

Group all current changes into meaningful semantic commits and push the current branch.

Optional context for commit messages: ``

Goal:

Build a professional commit history following:

* Conventional Commits
* Atomic commits
* Git Flow compatibility
* Clean future release tagging

Assumptions:

* Repository may have been freshly initialized.
* Do not create tags.
* Do not create develop.
* Do not modify branch strategy.
* Preserve only meaningful commit history.

---

## Step 1 — Load the app-changes skill and produce the changes table

Load:

`.opencode/skills/app-changes/SKILL.md`

Run:

```bash
git status --short

git diff --stat

git diff

git log --oneline -10
```

Output:

| Path | Changes |

User must clearly see what will be committed.

---

## Step 2 — Safety check

Scan changes for:

```txt
.env
.env.*
token
credential
secret
private
*.pem
*.key
```

If found:

STOP.

Ask user whether to:

* exclude
* convert to example
* intentionally include

Never commit secrets automatically.

---

## Step 3 — Plan commits

Using Step 1:

Group by intent:

```txt
feat
fix
refactor
test
docs
build
ci
chore
```

Rules:

* Create multiple commits for independent changes.
* Do not mix unrelated concerns.
* Prefer small atomic commits.
* Follow recent repository style.
* Use optional context only if accurate.

Output:

| Files | Message |

Example:

```txt
lib/feature/**
→ feat(auth): add login
→ feat(auth): implement jwt
→ test(auth): integration tests
→ feat(dashboard): create shell
→ feat(dashboard): analytics

README.md
→ docs(readme): redesign setup guide

macos/**
→ build(macos): configure debug networking
```

Show plan.

---

## Step 3.5 — CONFIRMATION REQUIRED

STOP.

Wait for explicit approval.

Accepted:

```txt
yes
approve
commit
execute
```

If modified:

Return to Step 3.

---

## Step 4 — Execute commits

For each group:

Stage:

```bash
git add <files>
```

For manual rename:

```bash
git add <new_path>

git rm <old_path>
```

Commit:

```bash
git commit -m "<semantic message>"
```

Rules:

* Do not revert changes
* Do not use --no-verify
* Do not amend commits
* Do not force push
* Include add/modify/delete/rename

---

## Step 5 — Push and summarize

Only after push confirmation:

```bash
git push
```

Output:

| Commit | Files | Message |

Example:

| short-sha | file1,file2 | feat(auth): implement JWT login |
