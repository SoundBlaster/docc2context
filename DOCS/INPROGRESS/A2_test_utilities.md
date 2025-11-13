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
- Extend the SwiftPM test target with new helper APIs plus unit tests that prove the helpers work (e.g., temporary directory cleanup, fixture read paths, snapshot diff clarity).
- Ensure future feature tests can depend on `XCTestCase` extensions without additional setup.
- Run `swift test` locally and in CI to validate helpers on Linux + macOS once A1 scaffolding lands.

## Dependencies
- Depends on **A1** (Swift package + CI scaffolding). Verify CLI/lib/test targets already exist before adding helper code.
- Requires at least one sample fixture placeholder or stub path; if fixtures are missing, create temporary dummy content for harness tests and document TODO for real bundles.

## Blocking Questions
- Do we want helpers in a dedicated test-only target/module (e.g., `Docc2ContextTestSupport`) or as `@testable import` utilities inside the main package?
- What snapshot file format best fits determinism needs (plain Markdown vs. hashed JSON) per PRD guidance?

## Subtasks & Checklist
- [ ] Review existing `Package.swift` structure from A1 and determine where to place helper sources.
- [ ] Prototype temporary directory helper with automatic teardown and add covering tests.
- [ ] Implement fixture loader API with relative path validation + unit tests referencing `Fixtures/`.
- [ ] Design a lightweight snapshot assertion utility (string comparison with diff output) and add proof tests.
- [ ] Update README/DEV docs if new testing conventions require contributor guidance.

## Immediate Next Action
Inspect A1 Swift package layout (targets, directories) and sketch where the `TestSupport` utilities should live before writing the first failing helper test.
