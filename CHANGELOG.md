# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versions prior to 1.1.0 predate this changelog and are tracked in the git history.

## [Unreleased]

## [1.1.2] - 2026-08-19

### Fixed

- Certificate pinning is now enforced only in environments that require it
  (`staging`/`production` via `requirePinnedCertificates`). Fixes the web demo
  (release build with the `dev` environment) staying stuck on the loading
  screen because `CertificatePinner` threw a `StateError` for empty pins.
- Startup no longer hangs if session restore fails: boot errors are logged and
  the app proceeds to the login screen.

## [1.1.1] - 2026-08-19

### Added

- Flutter Web demo published to GitHub Pages: `AppEnvironment.useHttps` is now
  configurable via `--dart-define=API_USE_HTTPS=true` (forces HTTPS on a
  non-443 API port, e.g. `https://tudesarrollador.com:5111`).
- `web/404.html` so GoRouter deep links survive a browser refresh on Pages.

### Changed

- `Build Web` CI gate (compile) and automatic web deployment to GitHub Pages
  via `.github/workflows/deploy-web.yml` (Pages Artifact model).

### Docs and Tooling

- README Live Demo section, check-count alignment, repo rename references and
  web demo documentation.

[1.1.2]: https://github.com/Andresit0/flutter-clean-architecture-sdd/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/Andresit0/flutter-clean-architecture-sdd/compare/v1.1.0...v1.1.1

## [1.1.0] - 2026-08-19

### Added

- Shared domain models in `lib/shared/models/`: `PatientEntity`, `ClinicalHistoryEntity` (+ 6 sub-entities) and `LabResultEntity` (+ sub-entities and enums).
- `lab_results` feature end-to-end: domain layer, infrastructure layer, presentation layer, router navigation, network endpoint with browser failure mapping, and database store + serializer.
- `fl_chart` wrapped behind the `ITrendChart` seam (trend chart capability).
- `SaveSessionUseCase` extracted from auth with codegen auth providers.
- `SeamNotBoundException` fail-fast seam type for unbound DI seams.
- Reusable state components (loading/empty/error) in the design system.

### Changed

- Online-first repository refactor: `OnlineFirstRepository` template-method base adopted by `clinical_history` and `lab_results` repositories.
- Clinical history card details split into section widgets.
- DIO network stack decomposed into error mapper, request and retry executors.
- Database abstracted behind the `IDatabaseHandle` facade (sembast-free).
- `AppEnvironment` refactored to a static-free sealed class.
- `lab_results` DTOs migrated to freezed and adapted to `OnlineFirstRepository`.
- `appNavigatorProvider` seam now throws `SeamNotBoundException` when unbound.
- Dependencies upgraded: `fl_chart`, `flutter_secure_storage` 11.0.0, `go_router` 17.5.0, `build_runner` 2.15.1.

### Docs and Tooling

- Documentation updates, AI tooling alignment (shared wire contracts, Rule 29) and CI/governance hardening (enterprise merge gates, dependabot policy).

[1.1.0]: https://github.com/Andresit0/flutter-clean-architecture-sdd/compare/v1.0.0...v1.1.0
