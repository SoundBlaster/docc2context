# A2 – XCTest Utilities & Snapshot Harness

## Objective
Stand up shared XCTest helpers so future CLI and pipeline tests can focus on behavior rather than boilerplate. Concretely this means:
- Utilities for creating and cleaning temporary directories used by conversion tests.
- Fixture loader helpers that read bundles from `Fixtures/` with provenance logging.
- Snapshot-style assertion helper that compares Markdown/link graph output with deterministic references.

## Relevant PRD Paragraphs
- `DOCS/PRD/docc2context_prd.md` §Phase A → Deliverable A2, describing "XCTest support utilities and snapshot harness" requirements.
- Determinism guardrails and fixture discipline sections emphasizing reproducible outputs and offline-friendly tooling.

## Test Plan
- Author failing unit tests first inside a dedicated `Docc2ContextTestSupportTests` suite that targets:
  - Temporary directory helpers (creation, cleanup, auto-teardown on failure paths).
  - Fixture loader API that verifies provenance logging and rejects unexpected relative paths.
  - Snapshot assertion helper that prints unified diffs when strings differ and honors deterministic fixtures.
- Use fixtures committed under `Fixtures/` (or temporary stubs recorded in `Fixtures/README.md`) so tests stay offline-friendly per PRD requirements.
- Extend the SwiftPM test target with the new helper sources and ensure they can be imported from future feature tests via `@testable import Docc2ContextTestSupport`.
- Run `swift test` locally (Linux + macOS) once A1 scaffolding lands to prove the helpers compile and execute under both toolchains.

## Validation & Checkpoints
- `swift test --filter Docc2ContextTestSupportTests/TemporaryDirectoryHelperTests`
- `swift test --filter Docc2ContextTestSupportTests/FixtureLoaderTests`
- `swift test --filter Docc2ContextTestSupportTests/SnapshotAssertionTests`
- Manual verification that generated snapshot files remain deterministic by hashing them twice (`shasum -a 256 path/to/snapshot`).
- README / developer docs updated with any new conventions so future contributors can run the same commands.

## Dependencies
- Depends on **A1** (Swift package + CI scaffolding). Verify CLI/lib/test targets already exist before adding helper code.
- Requires at least one sample fixture placeholder or stub path; if fixtures are missing, create temporary dummy content for harness tests and document TODO for real bundles.

### Current Dependency Status
- **A1:** Still in progress. Cannot add the `Docc2ContextTestSupport` target until the base package + CI are merged. Track readiness inside `DOCS/INPROGRESS/A1_*.md` (once available) before beginning implementation here.
- **Fixtures:** No canonical bundles yet. Accept a temporary stub fixture checked into `Fixtures/placeholder.docc` with provenance note, then replace once real bundles from the TODO list are sourced.

## Blocking Questions
- Do we want helpers in a dedicated test-only target/module (e.g., `Docc2ContextTestSupport`) or as `@testable import` utilities inside the main package?
- What snapshot file format best fits determinism needs (plain Markdown vs. hashed JSON) per PRD guidance?

## Subtasks & Checklist
- [ ] Review existing `Package.swift` structure from A1 and determine where to place helper sources (likely a `Docc2ContextTestSupport` target under `Tests/` plus shared sources).
- [ ] Sketch failing tests for temporary directory helper (`TemporaryDirectoryHelperTests`) before adding implementation.
- [ ] Implement helper + ensure automatic teardown occurs even when tests throw.
- [ ] Write fixture loader tests that assert provenance logging and guard against traversal attacks.
- [ ] Design and test a lightweight snapshot assertion utility (string comparison with context diff output, deterministic newline handling).
- [ ] Update README/DEV docs with a "How to use TestSupport" subsection describing imports, fixtures, and snapshot hygiene.

## Immediate Next Action
Coordinate with the A1 effort to confirm `Package.swift` exposes a slot for the `Docc2ContextTestSupport` target, then draft the first failing `TemporaryDirectoryHelperTests` case under `Tests/Docc2ContextTestSupportTests/` to drive the helper API design.
