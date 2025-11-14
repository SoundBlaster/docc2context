# B4 – Archive Extraction Pipeline

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
- 🔜 Need an `ArchiveExtractor` type plus CLI plumbing before Markdown conversion can consume normalized bundle paths.

## Execution Checklist
- [x] Review SELECT_NEXT output and confirm B4 as the active task.
- [x] Document scope, references, validation strategy, and fixtures within this note.
- [x] Update `DOCS/todo.md` with an "In Progress" annotation + link back to this plan.
- [x] Create test scaffolding file (`Tests/Docc2contextCoreTests/ArchiveExtractionTests.swift`) capturing the deterministic extraction scenarios.
- [ ] Add a deterministic archive-builder helper to `Tests/…/Support` so tests can wrap fixtures into `.doccarchive` inputs.
- [ ] Author failing tests in `ArchiveExtractionTests` covering deterministic paths, cleanup, and error propagation.
- [ ] Implement `ArchiveExtractor` (or equivalent module) plus CLI integration that satisfies the tests.
- [ ] Update README / CLI documentation with archive-specific usage notes if new flags or requirements emerge.
- [ ] Run the full suite + release gates before archiving this task.

## Blocking Questions / Coordination Notes
- Confirm whether Phase B must support both zipped `.doccarchive` files and directory-style archives, or if zipped-only coverage suffices until later phases.
- Decide whether extraction should rely on Foundation-only APIs (`FileManager` + `Compression`) or can shell out to `/usr/bin/unzip` for portability.
- Determine where generated archives should live during tests (temporary directory per test vs shared cache) to balance determinism with run time.

## Immediate Next Action
Finish the test harness work: implement a deterministic archive builder helper and convert the placeholder `ArchiveExtractionTests` into concrete failing specs that describe the expected extraction API surface (return type, cleanup handle, error enum). Once the tests clearly define the contract, begin implementing `ArchiveExtractor` to satisfy them.

## Progress Log
- 2025-02-14 — Completed START ritual: refreshed INPROGRESS note with scope + validation details, updated TODO entry, and added `ArchiveExtractionTests` scaffolding so failing tests can be authored next.
