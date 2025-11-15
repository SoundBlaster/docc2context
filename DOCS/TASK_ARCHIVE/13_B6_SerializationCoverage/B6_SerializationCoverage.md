# B6 Serialization Coverage

## Objective
Document and execute the work needed to serialize the internal DocC model (PRD Phase B6) so downstream Markdown snapshot tasks can depend on deterministic JSON representations of `DoccBundleModel`, tutorial volumes, and chapters.

## Relevant PRD Paragraphs
- [PRD/phase_b.md](../../PRD/phase_b.md#b6-internal-model) — requires codable representations of the internal model before Phase C renderers begin.
- [PRD/docc2context_prd.md](../../PRD/docc2context_prd.md#phase-b) — mandates determinism + fixture-driven validation for bundle models.

## First Failing Test to Author
- `DoccInternalModelSerializationTests.test_bundleModelIsCodable`: Asserts that `DoccBundleModel`, `DoccTutorialVolume`, and `DoccTutorialChapter` conform to `Codable` so they can be encoded with a deterministic JSON encoder. This is the immediate test being written now.

## Dependencies
- Archived B6 internal model builder implementation (`DOCS/TASK_ARCHIVE/11_B6_InternalModel/`).
- Tutorial catalog fixture (`Fixtures/TutorialCatalog.doccarchive`) already used by `InternalModelBuilderTests`.
- Shared fixture/test utilities from `Tests/Docc2contextCoreTests/Support/`.

## Blocking Questions
- Do we also need to serialize symbol references within this task, or can they remain raw until Markdown snapshot specs demand them?
- Are there ordering guarantees for topic sections beyond what `DoccDocumentationCatalog` already provides, or do we sort explicitly before encoding?

## Checklist & Sub-Steps
- [x] Add `Tests/Docc2contextCoreTests/InternalModelSerializationTests.swift` containing `DoccInternalModelSerializationTests.test_bundleModelIsCodable` (now green after wiring up `Codable` conformance).
- [x] Introduce a deterministic JSON encoder helper under `Tests/Docc2contextCoreTests/Support/DeterministicJSONEncoder.swift` so serialization consistently uses sorted keys, ISO-8601 dates, and unescaped slashes.
- [x] Expand serialization tests to round-trip the tutorial catalog model and lock the encoded payload via a JSON snapshot (`Tests/__Snapshots__/DoccInternalModelSerializationTests/tutorial-catalog.json`).
- [x] Update `DoccBundleModel` + nested types to conform to `Codable` so serialization tests can encode tutorial catalogs (array ordering already enforced by `DoccInternalModelBuilder`).
- [x] Wire serialization helper into future Markdown snapshot harnesses once tests pass via a reusable `JSONSnapshot` helper + `SNAPSHOT_RECORD` env flag.

## Validation Evidence — 2025-11-15
- `swift test --filter DoccInternalModelSerializationTests` while recording the JSON snapshot reference (see shell history 20:39 UTC).
- `swift test` (Linux) — exercises the CLI, parser, builder, and the new serialization tests to ensure there are no regressions.
- `Scripts/release_gates.sh` — reran `swift test`, the determinism smoke command (`swift run docc2context --help` twice), and fixture manifest validation to keep release gates green.

## Completion Summary
- Added the deterministic encoder/decoder helpers so every serialization test uses identical formatting, sorting, and ISO-8601 dates.
- Introduced `JSONSnapshot.assertSnapshot` + `SnapshotRecording` helpers and recorded the tutorial catalog snapshot at `Tests/__Snapshots__/DoccInternalModelSerializationTests/tutorial-catalog.json`.
- Expanded `DoccInternalModelSerializationTests` with `test_tutorialCatalogSerializationMatchesSnapshot` and `test_encoderProducesStableDataForTutorialCatalog`, covering end-to-end fixture parsing, builder wiring, JSON encoding, and round-trip decoding.
- Documented the snapshot workflow (`SNAPSHOT_RECORD=1`) in this note so future serialization or Markdown snapshot specs reuse the same pattern.

## Follow-Ups
- Feed the deterministic JSON encoder + snapshot helper into the upcoming C1 Markdown rendering outline so tutorial/article snapshots rely on the same tooling.
- Reference the archived snapshot in README (or Markdown spec docs) once C1 tasks start so developers know the canonical JSON structure that backs Markdown generation.
