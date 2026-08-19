# Repository Governance Bootstrap

This PR bootstraps the repository governance required before the enterprise
migration (README.md → Git Flow) can proceed. It covers:

1. **CODEOWNERS** — `.github/CODEOWNERS` maps ownership areas to real handles.
2. **Branch protection** — enforced on `develop` and `main` (push blocked,
   `enforce_admins`, strict required status checks, conversation resolution).
3. **Reviewers** — target state: `develop` requires 1 independent approval and
   code-owner reviews; `main` requires 2 approvals and code-owner reviews.
   **Personal-account exception (current):** this repository is maintained by a
   single human, and GitHub blocks self-approval, so `develop` runs with
   **0 required approvals** and `main` requires 2 in config. The operational
   gate is the required-check matrix plus an explicit human merge after CI is
   green. When an org/second reviewer is added, enable the target approval
   counts and update this file.
4. **Merge queue** — NOT available on a personal GitHub account. Documented
   exception per README.md → Git Flow: auto-merge only after all checks are green
   and a human control equivalent (reviewer approval) is required. When the
   repository moves to an enterprise plan, enable the merge queue and update
   this file.

## Verification

- Branch protection on `develop`: required checks `Analyze`, `Test`,
  `Build iOS`, `Build Android`, `Test Goldens`, `Gitleaks`, strict, 0 reviews
  (personal-account exception above), CODEOWNERS not required.
- Branch protection on `main`: adds `Branch Source Gate`, 2 reviews in config
  (personal-account exception applies), CODEOWNERS required.
- Merge queue: documented exception (personal plan limitation).
