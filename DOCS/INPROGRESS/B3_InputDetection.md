# B3 – Detect Input Type

## Objective
Implement deterministic detection + normalization of DocC bundle inputs so the CLI accepts directories or `.doccarchive` paths and produces a canonical bundle path for downstream parsing. This continues Phase B per the PRD after B2's argument parsing landed.

## References
- `DOCS/PRD/docc2context_prd.md` — Phase B table entry **B3 Detect Input Type** (normalize directories vs archives with unit tests).
- `DOCS/workplan.md` — Phase B sequencing calling for input detection before archive extraction, parsing, and modeling.
- `DOCS/todo.md` — In Progress entry added 2025-11-14 recording this selection.

## Dependencies & Preconditions
- ✅ **B1/B2** completed, so CLI already parses `input` argument + flags.
- ⏳ **A3 Fixtures** still active; plan to start with synthetic temp bundles (via A2 harness utilities) and later expand coverage using real fixtures once licensing resolved.
- ⚠️ Requires consistent error types/messages so CLI contract remains stable when detection fails (invalid path, missing `.doccarchive`, etc.).

## Working Theory & Scope Notes
1. Acceptable user inputs:
   - Directory that already ends with `.doccarchive` (DocC bundle folder).
   - Directory containing `.doccarchive`? (Should treat as bundle root only when structure matches DocC spec).
   - Compressed archive (likely `.doccarchive` packaged as `.doccarchive.zip` or `.doccarchive` file). For B3 we only need to recognize archives vs directories; extraction happens in B4.
2. Detection outputs:
   - Enum describing `case directory(URL)` vs `case archive(URL)` to feed B4.
   - Normalized canonical URL (absolute path, symlinks resolved) plus metadata (size, lastModified) for determinism logging.
3. Error handling: descriptive errors for missing input, unsupported extension, or path pointing at non-file/directory.

## Test Plan (initial sketch)
- Extend `Docc2contextCLITests` (or new `InputDetectionTests`) using the A2 temporary directory helpers.
- Cases:
  1. Directory path with `Info.plist`/`data/documentation` recognized as bundle root.
  2. Plain directory missing DocC markers triggers `invalidBundle` error.
  3. File ending in `.doccarchive` recognized as archive type (no extraction yet).
  4. Zip file wrapping `.doccarchive` recognized as archive type (if needed per PRD; confirm spec before coding).
  5. Nonexistent path yields `fileNotFound` error referencing original input string.
- Tests assert detection enum plus canonicalized paths.

## Open Questions / Follow-Ups
- Confirm whether zipped `.doccarchive` files should be accepted (PRD hints at archive support; double-check when drafting failing tests).
- Determine if we need to inspect bundle manifests to confirm DocC shape or if existence of `Info.plist` + `data` directory is enough at detection step.
- Coordinate with A3 once fixtures land to add integration tests referencing real bundles.

## Next Actions
1. Draft failing tests describing detection enum, canonicalization, and error surfaces (no production changes yet).
2. Define lightweight `InputLocation` type + error enum spec inside test to anchor API.
3. Revisit once tests exist to ensure B4 (extraction) can plug into resulting abstraction.
