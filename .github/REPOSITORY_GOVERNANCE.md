# Repository Governance Bootstrap

This PR bootstraps the repository governance required before the enterprise
migration (GIT_FLOW.md) can proceed. It covers:

1. **CODEOWNERS** — `.github/CODEOWNERS` maps ownership areas to real handles.
2. **Branch protection** — enforced on `develop` and `main` (push blocked,
   `enforce_admins`, strict required status checks, conversation resolution).
3. **Reviewers** — `develop` requires 1 independent approval and code-owner
   reviews; `main` requires 2 approvals and code-owner reviews.
4. **Merge queue** — NOT available on a personal GitHub account. Documented
   exception per GIT_FLOW.md §4.4: auto-merge only after all checks are green
   and a human control equivalent (reviewer approval) is required. When the
   repository moves to an enterprise plan, enable the merge queue and update
   this file.

## Verification

- Branch protection on `develop`: required checks `Analyze`, `Test`,
  `Build iOS`, `Build Android`, `Test Goldens`, `Gitleaks`, strict, 1 review,
  CODEOWNERS required.
- Branch protection on `main`: adds `Branch Source Gate`, 2 reviews, CODEOWNERS
  required.
- Merge queue: documented exception (personal plan limitation).
