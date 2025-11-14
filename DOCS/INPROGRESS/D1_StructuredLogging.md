# D1 – Structured Logging & Progress Reporting

## Objective
Stand up deterministic logging + progress reporting so the `docc2context` CLI can emit phase-by-phase updates (detection, extraction, parsing, generation) and summarize success/failure counts. This fulfills Phase D item **D1** after the CLI option parsing milestone (B2), giving us observability hooks before heavier parsing and Markdown work land.

## Relevant PRD Paragraphs
- `DOCS/PRD/docc2context_prd.md` — Phase D table entry **D1 Implement Logging & Progress** plus functional requirement §4.4 (logs detection/extraction/generation).
- `DOCS/PRD/phases.md` — reiterates Phase D acceptance checklist and highlights D1 as unblocked after B2.
- `DOCS/workplan.md` — confirms D1 depends on B2 only, so it can run in parallel while B3 proceeds.

## Dependencies & Preconditions
- ✅ **B2** CLI parsing complete; options struct surfaces inputs/flags for log context.
- 🚧 **B3** still active; coordinate so new logging enums/errors integrate cleanly once detection is implemented.
- ⚙️ XCTest harness + temporary directory utilities already exist from **A2** to drive log snapshot tests.

## Validation Plan
### Test Matrix
- Snapshot test verifying canonical log output for a successful dry-run pipeline (use stubs/mocks for later phases until real implementations exist).
- Failure-path test: missing input path surfaces `InputValidationError` log entry before exit.
- Determinism test comparing hashed log buffers from two identical runs.
- CLI integration test capturing stdout/stderr ensures summary banner appears even when conversions fail mid-way.

### Commands to Run
- `swift test --filter LoggingTests`
- `swift run docc2context <temp bundle> --output <tmp>` once logging integrated, to observe manual output.
- `Scripts/release_gates.sh` prior to archiving to uphold determinism and fixture integrity gates.

## Scope & Working Notes
1. Add a logging facade within `Sources/docc2contextCore/Logging/` that exposes deterministic `Logger`/`LogEvent` structures (no timestamps by default; rely on structured payloads for determinism).
2. CLI should emit:
   - Start/finish events for each pipeline phase (detect, extract, parse, generate, emit-summary).
   - Structured errors with reason + suggested follow-up.
   - Summary record counting bundles processed, pages exported, warnings, and elapsed steps.
3. Capture logs in tests via in-memory sink so snapshots do not depend on stdout ordering.
4. Provide human-readable stdout writer for real CLI runs (pretty-printed but deterministic ordering/formatting).
5. Avoid premature adoption of external logging libraries; rely on Foundation + custom formatting to keep SwiftPM deps minimal.
6. Ensure logs can be silenced/filtered by verbosity flag placeholder even if CLI flag arrives later.

## Execution Checklist
- [x] Review SELECT_NEXT note + TODO entry for D1 context.
- [x] Document scope, dependencies, and validation plan inside this INPROGRESS note per START runbook.
- [x] Update `DOCS/todo.md` entry with START annotation + link back to this note.
- [x] Create `LoggingTests` scaffolding under `Tests/Docc2contextCoreTests/` describing the pending scenarios.
- [ ] Flesh out failing `LoggingTests` that encode phase event expectations.
- [ ] Implement logger + CLI wiring to emit events throughout detection/extraction placeholders.
- [ ] Document logging usage (README/PRD addendum) once behavior stabilizes.
- [ ] Run release gates and archive task once acceptance criteria satisfied.

## Blocking Questions / Follow-Ups
- Confirm whether structured logging must surface precise timestamps or if deterministic step counters are sufficient for Phase D.
- Align with B3 implementers on the error taxonomy so logging encodes consistent reasons/status codes.

## Immediate Next Action
Expand the placeholder `LoggingTests` into concrete failing specs for the "happy path" event ordering (detect → extract → parse → generate → summary) so implementation work can begin from outside-in.

## Progress Log
- 2024-03-09 — SELECT_NEXT command run: chose D1 to parallelize with B3 so observability exists before archive extraction and parsing tasks ramp up.
- 2024-03-10 — START ritual: refreshed this plan, added blocking questions + execution checklist, updated TODO entry, and introduced `LoggingTests` scaffolding to begin TDD work.
