# Clean Architecture SDD Harness

[![CI](https://github.com/Andresit0/flutter-clean-architecture-sdd/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Andresit0/flutter-clean-architecture-sdd/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/Andresit0/flutter-clean-architecture-sdd/branch/develop/graph/badge.svg)](https://codecov.io/gh/Andresit0/flutter-clean-architecture-sdd)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.12-blue.svg)](https://dart.dev)
[![Live Demo](https://img.shields.io/badge/Live_Demo-GitHub_Pages-blue.svg)](https://andresit0.github.io/flutter-clean-architecture-sdd/)

## Live Demo

**https://andresit0.github.io/flutter-clean-architecture-sdd/**

A Flutter Web build of `main`, published automatically by
[`.github/workflows/deploy-web.yml`](.github/workflows/deploy-web.yml) on every
push to `main` (i.e. after each release).

> The demo runs **without a backend**: it talks to the public fake API at
> `https://tudesarrollador.com:5111` (clinical history + lab results) and
> **accepts any email/password** for login. It runs without certificate pinning
> (the `dev` environment does not enforce it). Just open the link and walk the
> flow **Login → Clinical History → Lab Results → Chart**.

Feature-first Flutter clean architecture template with Riverpod 3 codegen, a Result-based domain layer, and an AI-assisted SDD/TDD/BDD harness backed by enterprise CI/CD.

## Overview

A production-oriented Flutter starter that enforces clean architecture conventions by design and by CI:

- **Feature-first layout** — each feature owns its domain, infrastructure and presentation layers.
- **Riverpod 3 with codegen** — typed providers, composition root in `lib/app/di/`.
- **Result-based error handling** — `Result<T>` / `AppError` / `guard()` in `lib/shared/error/`; repositories never throw.
- **Package wrapper pattern** — every external package is wrapped (`<name>_wrapper.dart`); features never import packages directly.
- **AI-assisted workflow** — Spec-Local Orchestrator: spec definition, all-tests-first TDD, BDD scenarios, phase gates.
- **Enterprise CI/CD** — analyze, unit/widget, goldens, iOS/Android builds, gitleaks secret scan, codecov, dependabot auto-merge.

## Tech Stack

| Layer | Technology | Version |
|---|---|---|
| Runtime | Flutter / Dart | 3.44.0 / 3.12.0 |
| State management | flutter_riverpod + riverpod_annotation (codegen) | ^3.3.1 / ^4.0.3 |
| Models | freezed + json_serializable | ^3.1.0 / ^6.9.0 |
| Networking | dio | ^5.11.0 |
| Routing | go_router | ^17.5.0 |
| Local storage | sembast (+ sembast_web) | ^3.7.5+2 |
| Secure storage | flutter_secure_storage | ^11.0.0 |
| Auth/crypto | dart_jsonwebtoken, bcrypt, encrypt | ^3.1.1 / ^1.2.0 / ^5.0.3 |
| Device security | flutter_jailbreak_detection_plus | ^1.10.7 |
| Testing | mocktail, golden_toolkit, gherkart (BDD) | ^1.0.4 / ^0.15.0 / ^0.2.1 |

## Screenshots

> Screenshots are captured from the real app running on an iOS simulator against the dev backend (`localhost:5111`). Regenerate them after UI changes with:

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_capture_test.dart \
  -d <ios-simulator-id>
```

> The capture test (`integration_test/screenshots_capture_test.dart`) logs in with the dev credentials and captures `login_screen`, `clinical_history` and `lab_results` via the integration_test driver, writing the PNGs to `screenshots/`.

| Login | Clinical History | Lab Results |
|---|---|---|
| ![Login](screenshots/login_screen.png) | ![Clinical History](screenshots/clinical_history.png) | ![Lab Results](screenshots/lab_results.png) |

Demo flow: **Login → Clinical History → Lab Results** (the clinical history AppBar "Lab Results" action navigates to the lab results screen via the `IAppNavigator` seam).

## Architecture

```
lib/
├── app/            Composition root: GoRouter, guards, initializer, offline banner, DI seam bindings
├── core/           Infrastructure: network (dio wrapper, interceptors, retry), database (sembast), services (auth, crypto, device, storage), config
├── shared/         Domain abstractions: error (Result/AppError/guard), interfaces, models/entities, exceptions, online-first repository helper
├── features/       Feature-first modules: <name>/domain|infrastructure|presentation|di|spec
├── design_system/  Theme + reusable UI
└── l10n/           AppLocalizations (en/es)
```

Dependency rules (enforced by `test/architecture/dependency_rules_test.dart`):

- `domain/` imports only `shared/` — never `core/`, `app/`, or Flutter.
- `core/` is pure infrastructure; domain never depends on it.
- Features never import external packages directly — only wrappers from `core/services/`.
- No orphaned generated files — every `*.freezed.dart`/`*.g.dart` must have its sibling source (Rule 29).
- **Dependency policy** — the Flutter SDK (3.44.0) pins `intl` (0.20.2), `test_api` (0.7.11), `matcher`, `meta`, `vector_math` to exact versions; never force-bump them (breaks `flutter pub get`). Dependabot ignores `intl`/`test`/`freezed-major` (see `.github/dependabot.yml`). Never adopt prerelease-major codegen in production (freezed 4.0.0-dev.x is deferred until stable — issue #62). See `MD/APP_COMMANDS.md` and `.github/REQUIRED_CHECKS.md`.

Full details: [MD/APP_ARCHITECTURE.md](MD/APP_ARCHITECTURE.md)

## Repository Structure

- `lib/` — application source. Full tree: [MD/APP_TREE.md](MD/APP_TREE.md)
- `test/` — unit, widget, golden, architecture and BDD tests
- `integration_test/` — device integration tests
- `.ai/` — AI harness (skills, commands, orchestrators). See [AI Harness](#ai-harness)
- `MD/` — reference documentation (architecture, patterns, providers, commands, skills)
- `.github/workflows/` — CI/CD pipelines

## Quickstart

Prerequisites: Flutter 3.44 stable ([install](https://docs.flutter.dev/get-started/install)).

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate localization code (after cloning or modifying .arb files)
flutter gen-l10n

# 3. Generate Riverpod/freezed code (after modifying @riverpod or @freezed files)
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app (macOS example; env vars come from .env — see .env.example)
flutter run -d mac --dart-define-from-file=.env
```

## Testing

| Type | Command | Notes |
|---|---|---|
| Unit / widget | `flutter test --exclude-tags golden` | entities, use cases, mappers, repos, datasources, providers, notifiers |
| Golden | `flutter test --tags golden` | deterministic: embedded fonts + 2% tolerance (`golden` tag declared in `dart_test.yaml`) |
| Golden update | `flutter test --tags golden --update-goldens` | run after UI changes; commit PNGs |
| BDD | `flutter test test/bdd` | gherkart scenarios |
| Integration | `flutter test integration_test/auth_integration_test.dart -d macos` | needs device; run files individually (macOS runner caveat); no real HTTP (fakes injected via Riverpod) |
| Analyze | `flutter analyze` | 0 issues required before PR |

Cross-platform behavior (verified in CI):

| Platform | `flutter test` | `flutter test --tags golden` | CI job |
|---|---|---|---|
| macOS (local dev) | ✅ | ✅ (deterministic) | — |
| Linux (CI) | ✅ | ✅ (deterministic) | `Test` / `Test Goldens` |
| Windows (local dev) | ✅ | ✅ (deterministic) | — |
| Web (GitHub Pages) | ✅ | — | `Build Web` (compile gate) + `deploy-web.yml` (publish) |

Plain `flutter test` runs everything locally, including goldens (deterministic, embedded fonts). Use `--exclude-tags golden` for a unit/widget-only run — this is what the CI `Test` job does; `Test Goldens` runs `--tags golden`.

Mocks use `mocktail`; dependencies are replaced via Riverpod overrides — no real network calls in tests.

## CI/CD Gates

Every PR runs `.github/workflows/ci.yml` on `develop` and `main`; the same workflow also triggers on every push to `develop`/`main`, so each merge is followed by a post-merge verification run:

| Job | Purpose |
|---|---|
| Analyze | `flutter analyze`, 0 issues |
| Test | unit/widget (goldens excluded via `--exclude-tags golden`) + coverage upload to codecov (threshold 1%) |
| Test Goldens | golden tests, cross-platform deterministic |
| Build iOS | `flutter build ios --no-codesign` (macOS runner, CocoaPods cache) |
| Build Android | `flutter build apk --debug` |
| Build Web | `flutter build web --release --base-href /flutter-clean-architecture-sdd/` (demo defines, mirrors `deploy-web.yml`) |
| Gitleaks | secret scan gate (fail on leaked credentials) |
| Branch Source Gate | only on PRs to `main` — rejects heads not matching `release/*` or `hotfix/*` |

Dependabot updates are grouped and auto-merged (patch/minor) via [auto-merge.yml](.github/workflows/auto-merge.yml). Coverage configuration: [codecov.yml](codecov.yml).

## Git Flow

```
main ────── TAG vX.Y.Z            production (default branch)
  ▲  PR release/* | hotfix/*  (gate + 8 checks + 2 approvals in config; personal-account exception documented in .github/REPOSITORY_GOVERNANCE.md)
develop ──●──●──●                integration (all changes land here)
  ▲
feature/* | dependabot PRs
```

- `develop` — protected: PR required, 7 checks, 0 approvals (personal-account exception: single maintainer cannot self-approve; the gate is the required-check matrix plus an explicit human merge after CI is green — see `.github/REPOSITORY_GOVERNANCE.md`). Dependabot auto-merges patch/minor after checks pass.
- `main` — protected: PR required, 8 checks (incl. Branch Source Gate + Build Web), 2 approvals in config; only `release/*` and `hotfix/*` may merge. The same personal-account exception applies until an org/second reviewer exists.
- Feature branches are auto-deleted after merge; releases are tagged (annotated `vX.Y.Z`, e.g. `v1.1.0`).
- Releases and hotfixes are back-merged to `develop`.
- **Release procedure** — full runbook: `MD/APP_RELEASE.md` (preflight, cut point, release branch, CHANGELOG, squash merge to `main`, annotated tag, back-merge, GitHub Release).

## AI Harness

This repository is also a working AI development harness:

- **Orchestrator** — [Spec-Local Orchestrator v3](.ai/orchestrators/Spec-Local-Orchestrator.md): spec definition → phase gate → all-tests-first TDD → verification.
- **Skills** — 33 app skills (spec definition, TDD, test writers, fixers, nav-wiring, class-to-solid). Reference: [MD/APP_SKILLS.md](MD/APP_SKILLS.md)
- **Commands** — `super-commit`, `super-md-update`, `spec-local`, `super-pull-request*` in [.ai/commands](.ai/commands/)
- **Agent rules** — [AGENTS.md](AGENTS.md) (repo orientation for AI agents) and [MD/](MD/) reference docs (architecture, barrel pattern, package wrappers, providers, exceptions, dartz, tree).
- **Learning material** — [LEARN.md](LEARN.md)
- **Team rules** — 25 non-negotiable conventions (code, config, barrels, git, quality): [MD/APP_IMPORTANT_INFO.md](MD/APP_IMPORTANT_INFO.md)

## License

MIT — see [LICENSE](LICENSE).
