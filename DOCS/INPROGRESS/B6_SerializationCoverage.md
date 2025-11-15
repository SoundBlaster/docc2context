# B6 Serialization Coverage

## Summary
- **Goal:** add Codable serialization/round-trip coverage for `DoccBundleModel`, ensuring tutorial volumes and nested chapters produce deterministic JSON suitable for future Markdown snapshots.
- **Why now:** `DOCS/todo.md` lists this as the remaining Phase B testing gap after `DoccInternalModelBuilder` landed, and PRD §Phase B explicitly calls for serializing/deserializing the internal model before Phase C generators depend on it.

## Dependencies & Inputs
- B6 internal model implementation is complete and archived (see `DOCS/TASK_ARCHIVE/11_B6_InternalModel/`).
- Fixtures already cover tutorial catalogs and symbol references (`Fixtures/TutorialCatalog.doccarchive`).
- Existing coverage lives in `Tests/Docc2contextCoreTests/InternalModelBuilderTests.swift` and only asserts structure, not serialization determinism.

## Success Criteria
1. `DoccBundleModel`, `DoccTutorialVolume`, and `DoccTutorialChapter` conform to `Codable` (or equivalent) so tests can encode/decode JSON.
2. Add tests that encode a fixture-built model with a canonical `JSONEncoder` configuration (sorted keys) and verify round-trip equality + byte-for-byte determinism (e.g., compare SHA-256 of encoded data across two runs).
3. Document the serialization contract inside the test file (or helper) so downstream Phase C work can reuse the helper to persist snapshots.
4. All new tests run via `swift test` and the release gates script without flakiness.

## Planned Steps
1. Introduce a serialization helper inside `Tests/Docc2contextCoreTests/Support/` that centralizes deterministic JSON encoding (sorted keys, UTF-8 normalization).
2. Extend `DoccInternalModelBuilderTests` (or add `DoccInternalModelSerializationTests`) to:
   - Build the bundle model from `TutorialCatalog.doccarchive` using `DoccInternalModelBuilder`.
   - Encode to JSON, decode back, and assert equality with the original model.
   - Hash the encoded payload twice to confirm determinism even when invoked sequentially.
3. If additional fields require stable ordering (e.g., topic sections), update the builder or models to ensure arrays remain sorted before encoding.
4. Update documentation (README or developer notes) only if new helpers meaningfully change usage; otherwise leave to the separate "B6 Documentation Update" task.

## Validation Plan
- `swift test --filter DoccInternalModelBuilderTests`
- full `swift test`
- `Scripts/release_gates.sh` after serialization tests are in place

## Open Questions / Risks
- Do symbol references also need serialization in this task, or will Markdown generation stream directly from parsed references? If determinism issues arise, expand scope accordingly.
- Need to confirm whether hashed comparisons live in XCTest or a shared helper to avoid duplication when Markdown snapshots arrive.
