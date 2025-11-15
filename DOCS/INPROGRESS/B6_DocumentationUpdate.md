# B6 Documentation Update

## Objective
Document the internal model produced by `DoccInternalModelBuilder` so downstream Markdown tasks understand how `DoccBundleModel` aggregates bundle metadata, tutorial volumes, and symbol references. This update must spell out the deterministic ordering guarantees (tutorial volumes, chapters, and page identifiers) and surface how the serialized model is meant to drive upcoming Phase C snapshot work.

## Relevant PRD paragraphs
- **PRD §2 Phase B – B6** (DocC internal model definition + serialization tests).
- **PRD §3 Execution Metadata – B6 Acceptance Criteria** ("Model serialization tests" + expectation that Phase C consumes this contract).
- **Workplan §Phase B** entry for B6 completion + documentation readiness.

## First Failing Test to Author
- `InternalModelDocumentationTests.test_readmeDocumentsInternalModelMapping` – reads the README section bounded by `<!-- INTERNAL_MODEL_DOC_START -->` / `<!-- INTERNAL_MODEL_DOC_END -->` and asserts that it enumerates the struct names (`DoccBundleModel`, `DoccDocumentationCatalog`, `DoccTutorialVolume`, `DoccTutorialChapter`, `DoccSymbolReference`) plus explicitly states the ordering guarantees for tutorial volumes + chapters.

## Dependencies
- B6 internal model implementation + tests (`DOCS/TASK_ARCHIVE/11_B6_InternalModel/`).
- Fixtures from A3 powering the builder + serialization coverage.
- README baseline already documents CLI usage + metadata parsing so the new section must stay consistent with tone/style.

## Blocking Questions
- Should deeper developer docs (e.g., `DOCS/developer/internal_model.md`) be spun up alongside README, or is the README section + citations enough for Phase B scope?
- Do we want to embed a JSON snippet that mirrors the deterministic encoding (pending outcome of B6 Serialization Coverage task)? If yes, coordinate with that effort to avoid drift.

## Checklist
- [ ] Draft README section explaining each internal model struct, the fields surfaced so far, and why they exist.
- [ ] Capture ordering guarantees (volume list, chapter ordering, page identifiers) in prose and call out how determinism is enforced.
- [ ] Author `InternalModelDocumentationTests` that extract the README section and assert it references the required struct names + ordering language (failing before docs exist).
- [ ] Update README + any supporting docs until the test passes.
- [ ] Run `swift test` + `Scripts/release_gates.sh` to ensure the new documentation section and tests integrate cleanly.

## Validation Plan
- `swift test --filter InternalModelDocumentationTests`
- Full `swift test`
- `Scripts/release_gates.sh` once README + doc tests are green to ensure determinism/fixtures remain intact.

## Immediate Next Action
Create `InternalModelDocumentationTests` under `Tests/Docc2contextCoreTests/` with helpers that load README via `TestSupportPaths` and assert the new documentation markers/phrases exist. This test should fail until the README section lands, enforcing the documentation contract.
