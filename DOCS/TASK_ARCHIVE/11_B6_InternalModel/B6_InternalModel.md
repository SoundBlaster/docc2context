# B6 – Build Internal Model

## Objective
- Convert the parsed DocC metadata (Info.plist, render metadata, technology catalog, symbol graphs) into deterministic Swift structs that describe bundle-level context plus tutorial/article hierarchies ready for Markdown generation.
- Capture ordering guarantees, serialization hooks, and mapping notes so Phase C snapshot specs (C1) can rely on stable identifiers/titles without re-reading bundle files.

## Relevant PRD Paragraphs
- `DOCS/PRD/docc2context_prd.md` §2 (Phase B table) + §3 (Execution metadata) — B6 requires custom models validated by serialization tests before Markdown generation begins.
- `DOCS/PRD/phase_b.md` (B6 bullets) — reiterates that tutorials/articles/symbols must be represented by Swift structs with notes for downstream generators.

## First Failing Test to Author
- `DoccInternalModelBuilderTests.test_buildsTutorialVolumeOrderingFromCatalogFixture`
  - Uses `Fixtures/TutorialCatalog.doccarchive`.
  - Parses bundle metadata (`DoccMetadataParser`) then asserts the internal model builder emits a bundle model whose tutorial volume + chapter ordering mirrors the catalog topics and captures the identifiers needed for Phase C snapshot specs.
  - Verifies the symbol references are surfaced on the model for future link graph work.

## Dependencies
- ✅ B5 (`DoccMetadataParser`) supplies bundle metadata, documentation catalog, bundle data metadata, and symbol references.
- ✅ Fixtures from A3 ensure deterministic tutorial/article data.
- 🔜 Determinism scripts from A4 (`Scripts/release_gates.sh`) will be rerun once serialization tests exist.

## Validation Plan
- Author new XCTests under `Tests/Docc2contextCoreTests/` focused on the internal model builder: `swift test --filter DoccInternalModelBuilderTests`.
- Extend harness with serialization checks to ensure JSON encoding of `DoccBundleModel` is deterministic.
- When model layer is implemented, run `swift test` and `Scripts/release_gates.sh` for regression + determinism coverage.

## Checklist
- [x] Enumerate required tutorial/article/symbol fields by auditing DocC catalog + render nodes and log decisions in this note.
- [x] Write failing `DoccInternalModelBuilderTests.test_buildsTutorialVolumeOrderingFromCatalogFixture` (tutorial catalog fixture) that locks ordering + symbol exposure.
- [x] Implement `DoccInternalModelBuilder` + supporting structs so the test passes while keeping ordering deterministic.
- [ ] Add serialization test covering JSON round-trip + deterministic sorting for symbol references/topics.
- [ ] Update README/inline docs with mapping notes + link graph considerations for C1/C3.

## Blocking Questions
- Should link graph edges live directly on each `DoccPage` model or be computed lazily per Phase C? (Default: capture outgoing references array per page; revisit once page parsing begins.)
- How will localized content be represented? (Plan: keep base locale strings now with TODO hooks for locale expansion.)

## Completion Summary
- Authored `DoccBundleModel`, `DoccTutorialVolume`, and `DoccTutorialChapter` structs that retain the metadata, render info, bundle data metadata, catalog topics, tutorial ordering, and symbol references surfaced by `DoccMetadataParser`.
- Implemented `DoccInternalModelBuilder.makeBundleModel` to bridge the parsed assets into the internal model, guaranteeing deterministic ordering by sorting catalog topic sections and identifiers.
- Captured validation through `DoccInternalModelBuilderTests.test_buildsTutorialVolumeOrderingFromCatalogFixture` which exercises the `TutorialCatalog` fixture and asserts volume identifiers, titles, chapter ordering, and symbol passthrough, ensuring Phase C can consume stable identifiers.

## Validation Evidence
- `swift test` (Linux) — covers `DoccInternalModelBuilderTests` along with the existing CLI, parsing, and harness suites (see 2025-11-15 run in shell history).

## Follow-Ups
- Serialization determinism tests now live under `DOCS/TASK_ARCHIVE/13_B6_SerializationCoverage/` and should be referenced by any future model changes.
- Update the README / developer docs with the internal model mapping notes so future phases understand the available fields.

## Immediate Next Action
- Schedule serialization determinism coverage + README documentation follow-ups before kicking off Phase C snapshot specs (C1).
