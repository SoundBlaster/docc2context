# A1 – Bootstrap Swift Package & CI Skeleton

## Objective
Launch the foundational Swift Package Manager workspace that exposes a `docc2context` CLI target, shared library target, and XCTest bundle while remaining offline-friendly and aligned with PRD Phase A deliverable A1.

## Relevant PRD References
- `DOCS/PRD/docc2context_prd.md` §Phase A "Bootstrap CLI & Library" and tooling guardrails.
- `DOCS/workplan.md` Phase A checklist confirming A1 precedes the testing utilities task (A2).

## Dependencies
- Prerequisites: none. Completion unlocks A2 (XCTest support utilities) and all downstream CLI work.
- Inputs already reviewed: workplan, TODO list, and absence of conflicting `DOCS/TASK_ARCHIVE` entries.
- Linux toolchain requirements: `clang`, `libicu-dev`, `libatomic1`, and `libcurl4-openssl-dev` must be installed prior to invoking Swift (mirrors README + CI steps).
- macOS toolchain requirements: pin to Xcode 15.2 (Swift 5.9.2) locally and in CI using `maxim-lobanov/setup-xcode@v1` so the Darwin SDK matches the GitHub runner.

## Test Plan / Validation
- `swift build` and `swift test` locally plus via CI on Ubuntu 22.04 + macOS runners to ensure cross-platform builds (see `.github/workflows/ci.yml`).
- Verify Swift tools version (target 5.9.2) before every run; CI now logs `swift --version` explicitly and macOS runners select Xcode 15.2 before building.
- Placeholder unit tests confirming executable + library targets link successfully (`Docc2contextCommandTests`).
- Document Linux bootstrap guidance (README) so maintainers can reproduce CI locally; update this file if deviations occur.

## Execution Checklist
- [x] Scaffold Swift package (`swift package init --type executable`) and expand to CLI + shared library + tests.
- [x] Create placeholder CLI implementation exposing `--help` so CI builds succeed before feature work.
- [x] Add initial XCTest that exercises the CLI target wiring.
- [x] Author `.github/workflows/ci.yml` with `ubuntu-latest` & `macos-latest` matrix executing `swift test`.
- [x] Pin the macOS workflow job to Xcode 15.2 to avoid Swift open-source toolchains missing the Darwin SDK.
- [x] Document any tooling deviations or fixture needs discovered while bootstrapping (no blockers noted; targeting Swift 5.9).

## Blocking Questions
- Does the provided container include Swift 5.9 or do we need to pin to the latest available patch version?
- Should CI cache `.build` artifacts immediately or defer until determinism requirements are finalized?

## Immediate Next Action
Watch the refreshed CI run (Ubuntu + macOS with Xcode 15.2) to confirm there are no remaining toolchain crashes, then prepare the SELECT_NEXT command for task A2 hand-off once both jobs stay green.
