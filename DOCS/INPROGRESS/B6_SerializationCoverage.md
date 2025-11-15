# B6 Serialization Coverage

## Objective
Document and execute the work needed to serialize the internal DocC model (PRD Phase B6) so downstream Markdown snapshot tasks can depend on deterministic JSON representations of `DoccBundleModel`, tutorial volumes, and chapters.

## Relevant PRD Paragraphs
- [PRD/phase_b.md](../PRD/phase_b.md#b6-internal-model) — requires codable representations of the internal model before Phase C renderers begin.
- [PRD/docc2context_prd.md](../PRD/docc2context_prd.md#phase-b) — mandates determinism + fixture-driven validation for bundle models.

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
- [ ] Introduce a deterministic JSON encoder helper under `Tests/Docc2contextCoreTests/Support/DeterministicJSONEncoder.swift` (planned after conformance lands).
- [ ] Expand serialization tests to round-trip the tutorial catalog model and compare SHA-256 hashes of the encoded payload.
- [x] Update `DoccBundleModel` + nested types to conform to `Codable` so serialization tests can encode tutorial catalogs (array ordering already enforced by `DoccInternalModelBuilder`).
- [ ] Wire serialization helper into future Markdown snapshot harnesses once tests pass.

## Validation Plan
- `swift test --filter DoccInternalModelSerializationTests` for focused iterations.
- Full `swift test` before requesting review.
- `Scripts/release_gates.sh` to revalidate determinism + fixture hashes after serialization helpers ship.

## Immediate Next Action
Introduce the deterministic JSON encoder helper under `Tests/Docc2contextCoreTests/Support/DeterministicJSONEncoder.swift` so upcoming serialization tests can share consistent date formatting and sorted key output.
