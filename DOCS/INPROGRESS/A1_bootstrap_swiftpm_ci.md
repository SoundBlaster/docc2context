# A1 – Bootstrap Swift Package & CI Skeleton

## Objective
Launch the foundational Swift Package Manager workspace that exposes a `docc2context` CLI target, shared library target, and XCTest bundle while remaining offline-friendly and aligned with PRD Phase A deliverable A1.

## Relevant PRD References
- `DOCS/PRD/docc2context_prd.md` §Phase A "Bootstrap CLI & Library" and tooling guardrails.
- `DOCS/workplan.md` Phase A checklist confirming A1 precedes the testing utilities task (A2).

## Dependencies
- Prerequisites: none. Completion unlocks A2 (XCTest support utilities) and all downstream CLI work.
- Inputs already reviewed: workplan, TODO list, and absence of conflicting `DOCS/TASK_ARCHIVE` entries.

## Test Plan / Validation
- `swift test` locally and via CI on Ubuntu + macOS runners to ensure cross-platform builds (matrix wired in `.github/workflows/ci.yml`).
- Verify Swift tools version (target 5.9) during `swift package init` and note deviations in this file if needed (scaffold locked to 5.9).
- Placeholder unit tests confirming executable + library targets link successfully (`Docc2contextCommandTests`).

## Execution Checklist
- [x] Scaffold Swift package (`swift package init --type executable`) and expand to CLI + shared library + tests.
- [x] Create placeholder CLI implementation exposing `--help` so CI builds succeed before feature work.
- [x] Add initial XCTest that exercises the CLI target wiring.
- [x] Author `.github/workflows/ci.yml` with `ubuntu-latest` & `macos-latest` matrix executing `swift test`.
- [x] Document any tooling deviations or fixture needs discovered while bootstrapping (no blockers noted; targeting Swift 5.9).

## Blocking Questions
- Does the provided container include Swift 5.9 or do we need to pin to the latest available patch version?
- Should CI cache `.build` artifacts immediately or defer until determinism requirements are finalized?

## Immediate Next Action
Monitor the inaugural CI runs once the PR opens and prepare the SELECT_NEXT command for task A2 hand-off after confirming `swift test` passes remotely.
