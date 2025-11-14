# A2 – Provision TDD Harness

## Purpose & Scope
- **PRD Reference:** Phase A "Provision TDD Harness" (DOCS/PRD/docc2context_prd.md §Phase A, ID A2).
- **Goal:** Provide XCTest utilities (temporary directory mgmt, fixture loader) and Markdown snapshot helpers enabling red-green workflows before CLI implementation tasks.
- **Dependencies:** A1 bootstrap completed and archived; harness unblocks B1 CLI spec tests plus future fixture work.

## Current Context
- No other active tasks in `DOCS/INPROGRESS/`.
- TODO entry `A2` moved to In Progress per `DOCS/todo.md`.

## Deliverables & Acceptance Criteria
1. Shared XCTest support module (likely under `Tests/docc2contextTests/Support/`).
2. Temp directory + fixture loader utilities with deterministic naming and automatic cleanup.
3. Snapshot testing harness (consider `swift-snapshot-testing` or lightweight hashing) documented for Markdown/link outputs.
4. Example/spec tests proving harness can load fixtures and compare multi-file output deterministically.

## Risks / Open Questions
- Decide whether to vendor a snapshot-testing dependency vs custom helper to keep SwiftPM dependencies minimal.
- Need representative DocC fixtures (A3) soon; harness should tolerate missing fixtures by providing stubs/mocks.

## Completion Summary – 2025-11-14
- Added a reusable XCTest support surface under `Tests/Docc2contextCoreTests/Support/` that exposes deterministic temporary
  directories, fixture manifest loading, and Markdown snapshot helpers.
- Created `HarnessUtilitiesTests` to prove that the helpers create/clean temporary directories, parse `Fixtures/manifest.json`,
  and enforce Markdown snapshot comparisons with committed references.
- Seeded the inaugural snapshot under `Tests/__Snapshots__/HarnessUtilitiesTests/` to document how markdown specs will evolve
  once DocC conversion logic materializes.

## Validation Evidence
- `swift test` (Linux) exercises both the existing CLI spec tests and the new harness utilities (`HarnessUtilitiesTests`).

## Follow-Ups
1. Task **A3** will replace the placeholder entries inside `Fixtures/manifest.json` with real DocC bundles and use the loader
   helpers to validate checksum + provenance fields.
2. Snapshot coverage currently focuses on Markdown text; future tasks should extend helpers for JSON graph comparisons once the
   converter emits metadata files.
