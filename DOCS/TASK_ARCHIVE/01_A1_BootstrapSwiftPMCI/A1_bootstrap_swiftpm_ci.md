# A1 – Bootstrap Swift Package & CI Skeleton

## Objective
Launch the foundational Swift Package Manager workspace that exposes a `docc2context` CLI target, shared library target, and XCTest bundle while remaining offline-friendly and aligned with PRD Phase A deliverable A1.

## Relevant PRD References
- `DOCS/PRD/docc2context_prd.md` §Phase A "Bootstrap CLI & Library" and tooling guardrails.
- `DOCS/workplan.md` Phase A checklist confirming A1 precedes the testing utilities task (A2).

## Dependencies
- Prerequisites: none. Completion unlocks A2 (XCTest support utilities) and all downstream CLI work.
- Inputs already reviewed: workplan, TODO list, and absence of conflicting `DOCS/TASK_ARCHIVE` entries.
- Linux toolchain requirements: `clang`, `libicu-dev`, `libatomic1`, and `libcurl4-openssl-dev` must be installed prior to invoking Swift (mirrors README + CI steps). macOS builds explicitly select Xcode 16.4 so local contributors should match that release when possible.
- Toolchain version: Swift 6.1.2 across Linux + macOS to avoid mismatched SDK headers and `_stddef` module failures observed with 5.9.2.

## Test Plan / Validation
- `swift build` and `swift test` locally plus via CI on Ubuntu 22.04 + macOS runners to ensure cross-platform builds (see `.github/workflows/ci.yml`). macOS validation occurs after switching to Xcode 16.4 via `maxim-lobanov/setup-xcode` and uses the bundled Swift 6.1.2 toolchain.
- Verify Swift tools version (target 6.1.2) before every run; CI now logs `swift --version` and asserts the version string.
- Placeholder unit tests confirming executable + library targets link successfully (`Docc2contextCommandTests`).
- Document Linux bootstrap guidance (README) so maintainers can reproduce CI locally; update this file if deviations occur.

## Execution Checklist
- [x] Scaffold Swift package (`swift package init --type executable`) and expand to CLI + shared library + tests.
- [x] Create placeholder CLI implementation exposing `--help` so CI builds succeed before feature work.
- [x] Add initial XCTest that exercises the CLI target wiring.
- [x] Author `.github/workflows/ci.yml` with `ubuntu-latest` & `macos-latest` matrix executing `swift test`.
- [x] Document any tooling deviations or fixture needs discovered while bootstrapping (no blockers noted; targeting Swift 6.1.2).

## Blocking Questions
- Does the provided container include Swift 6.1.2 or do we need to pin to the latest available patch version?
- Should CI cache `.build` artifacts immediately or defer until determinism requirements are finalized?

## Immediate Next Action
Monitor the refreshed CI runs (Ubuntu 22.04 + macOS) with the unified Swift 6.1.2 toolchain (Xcode 16.4 on macOS, SwiftyLab on Linux), then prepare the SELECT_NEXT command for task A2 hand-off once both jobs stay green.

## Validation Evidence
- 2025-11-13 — `swift test` on Linux container. All package tests passed, confirming the CLI + library + test targets link and run successfully with Swift 6.1.2.
- GitHub Actions workflow (`.github/workflows/ci.yml`) mirrors the local commands above across Ubuntu 22.04 and macOS (Xcode 16.4) with toolchain validation in place.

## Follow-Ups
- Task **A2** (XCTest utilities + snapshot harness) is ready to start now that the SwiftPM package and CI matrix are stable.
- Continue monitoring CI logs for any Swift toolchain bumps so README + workflow configuration stay aligned.
