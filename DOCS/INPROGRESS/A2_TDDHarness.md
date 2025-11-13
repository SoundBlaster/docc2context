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

## Next Steps
1. Review XCTest helper patterns used in similar Swift CLI projects for determinism guarantees.
2. Prototype temp-directory utility and add unit tests verifying cleanup + collision resistance.
3. Evaluate snapshot strategy (hash vs textual diff) and document choice in this file.
4. Update README/testing docs once utilities land so subsequent tasks know how to invoke harness.
