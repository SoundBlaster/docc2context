# B3 – Detect Input Type

## Objective
Implement deterministic detection and normalization of DocC bundle inputs so the CLI accepts directories or `.doccarchive` paths and produces a canonical bundle path for downstream parsing. This fulfills Phase B item **B3** in the PRD following the completion of argument parsing (B2).

## Relevant PRD Paragraphs
- `DOCS/PRD/docc2context_prd.md` — Phase B checklist entry **B3 Detect Input Type** covering bundle vs archive recognition and normalization rules.
- `DOCS/PRD/phases.md` — Phase B sequencing that gates archive extraction (B4) on solid detection results.
- `DOCS/workplan.md` — Notes on dependency order after argument parsing.

## Dependencies & Preconditions
- ✅ **B1/B2** finished; CLI already parses the `input` argument plus `--output/--force/--format` flags.
- ⏳ **A3 Fixtures** remain in-flight. Until the curated bundles land, rely on the A2 harness utilities to synthesize temporary DocC-like structures.
- ⚠️ Need consistent error types/messages so CLI contracts remain stable when detection fails (missing path, unsupported extension, malformed bundle, etc.).

## Working Theory & Scope Notes
1. Acceptable user inputs:
   - Directory that already ends with `.doccarchive` (DocC bundle folder).
   - Plain directory containing DocC markers (`Info.plist` + `data/documentation`).
   - File ending in `.doccarchive` (treated as archive input for future extraction logic).
   - Potential zipped `.doccarchive` support — confirm spec before expanding scope.
2. Detection outputs:
   - Enum such as `InputLocation` describing `.directory(URL)` vs `.archive(URL)` to feed B4.
   - Normalized canonical URL (absolute path, symlinks resolved) plus metadata for determinism logging.
3. Error handling: descriptive errors for missing input, unsupported extension, or path pointing at non-file/directory.

## Validation Plan
### Test Matrix
- Directory path with `Info.plist` + `data/documentation` recognized as bundle root.
- Plain directory missing DocC markers triggers `invalidBundle` error.
- File ending in `.doccarchive` recognized as archive type (no extraction yet).
- (Optional) Zip file wrapping `.doccarchive` recognized as archive type — blocked on PRD confirmation.
- Nonexistent path yields `fileNotFound` error referencing the original input string.

### Commands to Run
- `swift test --filter InputDetectionTests` — exercises new failing tests and future implementation.
- `swift run docc2context <synthetic bundle> --output <tmp>` — sanity check manual end-to-end flow once detection hooks into CLI.
- Release gate script (`Scripts/release_gates.sh`) before ARCHIVE to ensure determinism + fixture validation.

## Execution Checklist
- [x] Review SELECT_NEXT note + TODO entry for B3 context.
- [x] Document scope, references, and validation plan inside this INPROGRESS note.
- [x] Update `DOCS/todo.md` entry with link + "In Progress" annotation.
- [x] Create test scaffolding file (`Tests/Docc2contextCoreTests/InputDetectionTests.swift`) capturing pending scenarios.
- [ ] Flesh out failing tests describing the detection enum + error surfaces via the A2 harness utilities.
- [ ] Implement detection module (`Sources/docc2contextCore/InputDetection/...`) satisfying the tests.
- [ ] Integrate detection results into the CLI pipeline and update README usage examples.
- [ ] Add fixture-backed tests once A3 delivers real DocC bundles.
- [ ] Run release gates prior to archiving this task.

## Blocking Questions / Follow-Ups
- Confirm whether zipped `.doccarchive` files must be accepted in Phase B or later phases.
- Determine minimum inspection necessary to declare a directory a valid DocC bundle (is `Info.plist` + `data` enough?).
- Coordinate with A3 once fixtures land to add integration tests referencing real bundles.

## Immediate Next Action
Write concrete failing tests in `InputDetectionTests` that use the temporary directory helpers to synthesize DocC-like bundles and assert the detection enum + canonicalized paths. Begin with the directory success/failure cases before extending to file inputs.

## Progress Log
- 2024-03-09 — Ran START command ritual: expanded this note with validation plan + checklist and added `InputDetectionTests` scaffolding so coding can begin next.
