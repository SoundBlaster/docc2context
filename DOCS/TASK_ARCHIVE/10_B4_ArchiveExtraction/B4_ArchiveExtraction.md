# B4 – Archive Extraction Pipeline

## Addendum — 2025-12-18 (Current Contract)

The repository’s current, tested behavior treats `.doccarchive` **directories** as DocC bundles and rejects `.doccarchive` **files** with explicit extraction guidance. Automatic extraction of `.doccarchive` files is not implemented in the current codebase (see `Docc2contextCLITests.testArchiveInputProvidesExtractionGuidance` and `Sources/Docc2contextCore/InputLocationDetector.swift`).

This archive note is retained for historical context and describes an earlier plan/implementation narrative that is superseded by the current contract.

## Objective
Deterministically extract `.doccarchive` inputs into sanitized temporary directories so the CLI always hands a normalized DocC bundle path to downstream phases. This work satisfies PRD Phase B item **B4 Extract Archive Inputs** and enforces cleanup semantics plus descriptive failure messaging.

## Relevant PRD Paragraphs
- `DOCS/PRD/docc2context_prd.md` — Phase B checklist entry **B4** covering archive extraction, determinism, and cleanup requirements.
- `DOCS/workplan.md` — Phase B dependency notes that gate Markdown generation on reliable archive extraction.
- `DOCS/PRD/phases.md` — Phase B acceptance criteria plus verification checklist for extraction determinism and error propagation.

## Test Plan
### Scenarios to Cover
1. **Deterministic Temp Roots** — Given the same `.doccarchive` input twice, extraction returns identical temporary directory paths (hash-based naming) and surfaces the canonical bundle root.
2. **Cleanup on Success & Failure** — Temporary directories are removed when the extraction context drops or when conversion errors propagate past extraction.
3. **Error Surfacing** — Corrupted archives or inputs missing DocC markers raise descriptive errors that reach the CLI with the appropriate exit code.
4. **Fixture Coverage** — Use curated bundles from `Fixtures/` (e.g., tutorial + API samples) wrapped in deterministic `.doccarchive` archives to assert behavior on real data.

### Commands
- `swift test --filter ArchiveExtractionTests` — Targeted suite for new extraction scenarios.
- `swift test` — Full regression pass before ARCHIVE/STATE updates.
- `Scripts/release_gates.sh` — Determinism guard (hashing + fixture validation) before closing the task.

### Fixtures & Utilities
- Extend the existing `TestTemporaryDirectory` helper with an archive builder utility that zips fixture bundles into `.doccarchive` files inside deterministic scratch space.
- Track fixture hashes + generated archive names inside the INPROGRESS note for repeatability.

## Dependencies & Preconditions
- ✅ **B1–B3** complete: CLI arguments, parsing, and basic input detection already exist.
- ✅ **A2/A3** deliver harness utilities + DocC bundle fixtures needed to synthesize `.doccarchive` test inputs.
- ✅ Archive builder helper (`DeterministicArchiveBuilder`) ensures `.doccarchive` fixtures mirror canonical DocC bundles before extraction begins.

## Execution Checklist
- [x] Review SELECT_NEXT output and confirm B4 as the active task.
- [x] Document scope, references, validation strategy, and fixtures within this note.
- [x] Update `DOCS/todo.md` with an "In Progress" annotation + link back to this plan.
- [x] Create test scaffolding file (`Tests/Docc2contextCoreTests/ArchiveExtractionTests.swift`) capturing the deterministic extraction scenarios.
- [x] Add a deterministic archive-builder helper to `Tests/…/Support` so tests can wrap fixtures into `.doccarchive` inputs.
- [x] Author failing tests in `ArchiveExtractionTests` covering deterministic paths, cleanup, and error propagation.
- [x] Implement `ArchiveExtractor` plus CLI integration that satisfies the tests.
- [x] Update README / CLI documentation with archive-specific usage notes if new flags or requirements emerge.
- [x] Run the full suite + release gates before archiving this task.

## Progress Log
- 2025-02-14 — Completed START ritual: refreshed INPROGRESS note with scope + validation details, updated TODO entry, and added `ArchiveExtractionTests` scaffolding so failing tests can be authored next.
- 2025-11-13 — Introduced `DeterministicArchiveBuilder` so fixture DocC bundles can be zipped into canonical `.doccarchive` files with reproducible hashes.
- 2025-11-14 — Added failing tests for deterministic extraction, cleanup-on-error, and corrupted archive propagation. Tests assert temp directory naming (SHA-256 seeded) plus lifecycle cleanup semantics.
- 2025-11-15 — Implemented `ArchiveExtractor` with hash-derived temp directories, cleanup handles, and typed errors surfaced through the CLI. Updated README usage examples, validated with `swift test --filter ArchiveExtractionTests`, `swift test`, and `Scripts/release_gates.sh` before moving to ARCHIVE.

## Completion Summary — 2025-11-15
- Added fixture-backed `ArchiveExtractionTests` that cover deterministic path generation, cleanup on both success/failure, and corrupted archive reporting.
- Implemented `ArchiveExtractor` + CLI wiring so `.doccarchive` inputs automatically extract into sanitized temporary directories with lifecycle-managed cleanup.
- Documented archive support in the README and ensured release gates cover double-run determinism plus fixture hash validation for the new `.doccarchive` assets.

## Validation Evidence
- `swift test --filter ArchiveExtractionTests`
- `swift test`
- `Scripts/release_gates.sh`

## Follow-Ups
- Monitor extraction performance on very large archives; consider streaming unzip if runtimes exceed PRD thresholds.
- Evaluate caching of extracted archives for Phase C determinism tests once Markdown generation lands.
