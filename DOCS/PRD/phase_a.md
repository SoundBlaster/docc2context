# Phase A – Quality & Deployment Foundations

**Progress Tracker:** `4/4 tasks complete (100%)`

- [x] **A1 – Bootstrap Swift Package & CI Skeleton**
  - Scaffold SwiftPM package with CLI, shared library, and XCTest targets.
  - Add GitHub Actions workflows that execute `swift test` for Linux and macOS on every push.
  - Commit initial README blurb describing the CLI entry point so CI logs have context.
- [x] **A2 – Provision TDD Harness**
  - Implement XCTest utilities plus snapshot/golden comparison helpers shared across suites.
  - Document how to invoke the harness within CONTRIBUTING/README to enforce tests-first flow.
  - Ensure failing placeholder tests exist so implementation must satisfy them before merging.
- [x] **A3 – Establish DocC Sample Fixtures**
  - Gather DocC bundles (tutorial, article, symbol-heavy) under `Fixtures/` with a manifest describing each sample.
  - Add automation to fetch or synthesize fixtures reproducibly (scripted download or generator).
  - Wire fixtures into the test harness to unblock parser and generator tests.
- [x] **A4 – Define Deployment & Release Gates**
  - Write release checklist covering tests, linting, determinism hashing, and artifact packaging.
  - Provide shell scripts (e.g., `Scripts/validate_release.sh`) that fail fast if any gate regresses.
  - Document gating steps inside README/PRD to set expectations for future releases.
