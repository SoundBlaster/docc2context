# F4 Dogfood DocC Fixture from Sources

**Status:** Implementation complete (ready to archive)  
**Owner:** docc2context agent  
**Selected on:** 2025-12-18  
**PRD reference:** `DOCS/PRD/docc2context_prd.md` (Post-MVP Enhancements, F4)  
**Workplan reference:** `DOCS/workplan.md` (Phase F, F4)  
**Related archive:** `DOCS/TASK_ARCHIVE/42_S0_DocCGenerationNotes/DocCGenerationNotes.md`

## Objective
Add real DocC documentation in `Sources/` for this package and use the generated `.doccarchive` as a first-party, realistic fixture under `Fixtures/` to increase coverage and dogfood the converter against “real Swift code” docs.

## Why now
- The repo already supports `.doccarchive` **directories** as inputs and already enforces fixture manifest discipline + deterministic snapshot testing.
- Existing fixtures are synthetic; this adds coverage for “real-world” symbol graph + DocC output shapes without relying on network access.

## Scope (what START should deliver)
1. **Docs in `Sources/`**
   - Add DocC documentation via DocC comments and/or a `.docc` documentation catalog suitable for `swift package generate-documentation`.
2. **Generated fixture committed under `Fixtures/`**
   - Generate a `.doccarchive` directory from the package (via `swift package generate-documentation`).
   - Commit the archive directory as a fixture with provenance notes (toolchain version, command line, host details).
   - Register the new fixture in `Fixtures/manifest.json` and any required `Fixtures/README.md` provenance notes.
3. **Tests**
   - Add XCTest coverage proving the converter can parse and generate deterministic Markdown + link graph output from the new fixture.
   - Do **not** require DocC generation at test time; tests consume committed fixture artifacts only.

## Non-goals
- Generating DocC during `swift test` (tests must remain offline-friendly and stable).
- Expanding CLI surface area unless required to make fixture conversion viable.

## Risks / constraints
- DocC output can change across Swift toolchains; fixture provenance must record the exact toolchain used to generate it.
- Fixture size: keep the initial DocC surface area small enough to avoid ballooning the repo while still being “real”.
- Determinism: generated docs must not embed host-specific absolute paths; if present, mitigation must happen at generation time or via fixture selection.

## Validation plan (START)
- `python3 Scripts/validate_fixtures_manifest.py Fixtures/manifest.json`
- `swift test` (full suite) and any focused filters added for the new fixture coverage
- `python3 Scripts/lint_markdown.py`
- Optional (if it remains within existing release-gate expectations): `Scripts/release_gates.sh`

## Proposed execution steps (for START)
1. Add minimal DocC docs in `Sources/` (aim for a small set of documented APIs and at least one article/tutorial if feasible).
2. Generate `.doccarchive` into a stable fixture path under `Fixtures/`.
3. Update fixture manifest + provenance documentation.
4. Add/extend snapshot and determinism tests to lock behavior.
5. Run validation commands and ensure CI-facing checks remain green.

## Follow-ups (only if START reveals scope creep)
- If the “docs in Sources” and “fixture + tests” work is too large for one session, split into `F4.1` (Docs + generation plumbing) and `F4.2` (Fixture commit + tests) in `DOCS/todo.md` before implementation starts.

## Implemented (START)
- Added a real DocC catalog for the `Docc2contextCore` module under `Sources/Docc2contextCore/Docc2contextCore.docc/` including the `Fixture dogfooding` article.
- Added `Fixtures/Docc2contextCore.doccarchive` generated from the package sources via `swift package generate-documentation` and then pruned to `metadata.json` + `data/documentation/` for offline converter tests.
- Updated `DoccMetadataParser` + `MarkdownGenerationPipeline` to support Swift-DocC render archives (DocC “render node” JSON) alongside the existing synthetic fixture schema.
- Added `Docc2contextCoreDoccFixtureTests` to validate conversion + determinism on the generated fixture.

## Validation evidence
- `python3 Scripts/lint_markdown.py`
- `python3 Scripts/validate_fixtures_manifest.py Fixtures/manifest.json`
- `swift test` (163 tests, 6 skipped, 0 failures)

## Notes
- The fixture is pinned to the committed `Fixtures/Docc2contextCore.doccarchive` contents and does not regenerate during tests.
- Regeneration requires the Swift-DocC plugin (`swift-docc-plugin`) dependency and should update `Fixtures/manifest.json` accordingly.
