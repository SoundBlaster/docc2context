# D1 – Structured Logging & Progress Reporting

## Objective
Stand up deterministic logging + progress reporting so the `docc2context` CLI can emit phase-by-phase updates (detection, extraction, parsing, generation) and summarize success/failure counts. This fulfills Phase D item **D1** after the CLI option parsing milestone (B2), giving us observability hooks before heavier parsing and Markdown work land.

## Reference Material
- `DOCS/PRD/docc2context_prd.md` — Phase D table entry **D1 Implement Logging & Progress** plus functional requirement §4.4 (logs detection/extraction/generation).
- `DOCS/workplan.md` — confirms D1 depends on B2 only, so it can run in parallel while B3 proceeds.
- `DOCS/todo.md` — now tracks D1 as "In Progress" with this note as the authoritative plan.
- `DOCS/INPROGRESS/B3_InputDetection.md` — upstream consumer; logging must reflect its success/error paths.

## Dependencies & Preconditions
- ✅ **B2** CLI parsing complete; options struct surfaces inputs/flags for log context.
- 🚧 **B3** still active; coordinate so new logging enums/errors integrate cleanly once detection is implemented.
- ⚙️ XCTest harness + temporary directory utilities already exist from **A2** to drive log snapshot tests.

## Scope & Working Notes
1. Add a logging facade within `Sources/docc2contextCore/Logging/` that exposes deterministic `Logger`/`LogEvent` structures (no timestamps by default; rely on structured payloads for determinism).
2. CLI should emit:
   - Start/finish events for each pipeline phase (detect, extract, parse, generate, emit-summary).
   - Structured errors with reason + suggested follow-up.
   - Summary record counting bundles processed, pages exported, warnings, and elapsed steps.
3. Capture logs in tests via in-memory sink so snapshots do not depend on stdout orderings.
4. Provide human-readable stdout writer for real CLI runs (pretty-printed but deterministic ordering/formatting).
5. Avoid premature adoption of external logging libraries; rely on Foundation + custom formatting to keep SwiftPM deps minimal.
6. Ensure logs can be silenced/filtered by verbosity flag placeholder even if CLI flag arrives later.

## Validation Plan
### Test Matrix
- Snapshot test verifying canonical log output for a successful dry-run pipeline (use stubs/mocks for later phases until real implementations exist).
- Failure-path test: missing input path surfaces `InputValidationError` log entry before exit.
- Ensure repeated runs yield byte-identical log output (determinism check in test comparing hashed logs from two runs).
- CLI integration test capturing stdout/stderr ensures summary banner appears even when conversions fail mid-way.

### Commands to Run
- `swift test --filter LoggingTests`
- `swift run docc2context <temp bundle> --output <tmp>` once logging integrated, to observe manual output.
- `Scripts/release_gates.sh` prior to archiving to uphold determinism and fixture integrity gates.

## Execution Checklist
- [ ] Design `LogEvent` model + sink abstraction supporting test capture and stdout writer.
- [ ] Author failing `LoggingTests` describing expected event sequences + summary snapshots.
- [ ] Implement logger + CLI wiring to emit events throughout detection/extraction placeholders.
- [ ] Document logging usage (README/PRD addendum) once behavior stabilizes.
- [ ] Run release gates and archive task once acceptance criteria satisfied.

## Immediate Next Action
Draft failing `LoggingTests` that simulate a minimal pipeline run using stubs for detection/extraction so we can TDD the event ordering + summary formatting before real implementations land.

## Progress Log
- 2024-03-09 — SELECT_NEXT command run: chose D1 to parallelize with B3 so observability exists before archive extraction and parsing tasks ramp up.
