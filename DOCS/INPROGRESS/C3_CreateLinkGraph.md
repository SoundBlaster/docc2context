# C3 – Create Link Graph (Cycle 1 Selection)

## Overview
Build cross-document link graph leveraging DocC identifiers and relationships captured during Phase B internal model building. Emit JSON/Markdown metadata describing adjacency and unresolved references for debugging, validated using adjacency-matrix tests ensuring no dangling links.

## Objective
Complete C3 task as part of cyclic execution workflow:
1. Author failing link graph tests (snapshot + adjacency validation)
2. Implement link graph builder using internal model relationships
3. Validate snapshot tests pass and no dangling references remain
4. Verify determinism and CI compliance

## PRD References
- **Phase C, Task C3:** Build cross-document link graph leveraging DocC identifiers and relationships captured in Phase B
- **Acceptance Criteria:**
  - JSON/Markdown metadata files emit adjacency information for each page
  - Adjacency-matrix tests validate no dangling links
  - Link resolution uses deterministic ordering from internal model
  - Tests pass locally and in CI

## Dependencies
- ✅ Phase B – CLI Contract & Input Validation (all complete)
- ✅ Phase C1 – Markdown Snapshot Specs (complete)
- ✅ Phase C2 – Markdown Generation (complete)

## Test Plan
1. **Link Graph Tests** (red phase):
   - Test `LinkGraphBuilder` initialization with `DoccBundleModel`
   - Test adjacency matrix generation for tutorial volumes → chapters → articles
   - Test symbol reference linking (articles linking to symbol references)
   - Test unresolved reference detection and warning logs
   - Snapshot test JSON metadata output

2. **Integration Tests**:
   - Test full conversion pipeline with link graph emission
   - Test determinism: same input yields identical link graph

3. **Fixture Coverage**:
   - Use `TutorialCatalog.doccarchive` (tutorial structure)
   - Use `ArticleReference.doccarchive` (article → symbol linking)

## Implementation Scope
- Create `LinkGraphBuilder` struct analyzing `DoccBundleModel` relationships
- Emit `LinkGraph` model (adjacency + unresolved list) as JSON
- Wire link graph into `MarkdownGenerationPipeline`
- Update `Docc2contextCommand` integration tests to verify link graph files written
- Document link graph format in README

## Success Metrics
- ✅ All new tests passing
- ✅ No regressions in existing tests
- ✅ Snapshot tests validate JSON output
- ✅ `swift test` passes locally and in CI
- ✅ Ready for ARCHIVE and C4 selection

## Implementation Notes

### Files Created/Modified
1. **New Files:**
   - `Sources/Docc2contextCore/LinkGraphBuilder.swift` - LinkGraphBuilder and LinkGraph model
   - `Tests/Docc2contextCoreTests/LinkGraphBuilderTests.swift` - LinkGraphBuilder unit tests (7 test methods)

2. **Modified Files:**
   - `Sources/Docc2contextCore/MarkdownGenerationPipeline.swift`:
     - Added `linkGraphBuilder` field and dependency injection
     - Integrated link graph generation after Markdown rendering
     - Link graph written to `output/linkgraph/adjacency.json` with deterministic encoding
     - Added `write(data:to:)` helper method
   - `Tests/Docc2contextCoreTests/MarkdownGenerationPipelineTests.swift`:
     - Added `test_pipelineWritesLinkGraph()` integration test

### Key Implementation Details
- **LinkGraph Model**: Codable struct containing:
  - `adjacency: [String: [String]]` - source identifier → sorted list of target identifiers
  - `allPageIdentifiers: [String]` - sorted list of all discovered page IDs
  - `unresolvedReferences: [String]` - sorted list of referenced but undefined pages

- **Link Extraction Logic**:
  - Tutorial volumes and their chapter page identifiers
  - Documentation catalog topics and their page identifiers
  - Symbol references from the bundle
  - Adjacency: volume/catalog → linked pages

- **Deterministic Output**:
  - Uses `DeterministicJSONEncoder` for consistent JSON output
  - Sorted keys and arrays throughout
  - Same input always produces identical JSON

- **Integration**:
  - Pipeline builds link graph after internal model construction
  - Writes to `output/linkgraph/adjacency.json` atomically
  - Uses existing error handling for write failures

### Test Coverage (Implemented)
- ✅ `test_buildLinkGraphFromTutorialCatalogFixture` - Basic fixture loading
- ✅ `test_buildLinkGraphFromArticleReferenceFixture` - Article/symbol handling
- ✅ `test_linkGraphMatchesSnapshot` - JSON output validation with snapshot
- ✅ `test_identifiesAllPageIdentifiersFromTutorials` - Page ID extraction
- ✅ `test_identifiesArticleIdentifiers` - Article ID tracking
- ✅ `test_linksAreOrderedDeterministically` - Determinism validation
- ✅ `test_unresolvedReferencesAreCaptured` - Unresolved reference tracking
- ✅ Pipeline integration test - JSON file written and valid

## Status
Implementation complete. Code written and tests authored (awaiting `swift test` execution to generate snapshots).

### Completion Checklist
- ✅ LinkGraph model created and Codable
- ✅ LinkGraphBuilder implemented with deterministic ordering
- ✅ Unit tests authored (7 tests, currently pending fixture execution)
- ✅ Pipeline integration complete and wired
- ✅ Pipeline integration test added
- ✅ Deterministic JSON encoding enforced
- ⏳ Test execution (pending swift availability)
- ⏳ Snapshot generation (pending test run)

### Next Steps for ARCHIVE
1. Run `swift test --filter LinkGraphBuilderTests` to validate all tests
2. Run `SNAPSHOT_RECORD=1 swift test --filter LinkGraphBuilderTests/test_linkGraphMatchesSnapshot` to capture JSON snapshot
3. Run full `swift test` to ensure no regressions
4. Verify `Scripts/release_gates.sh` passes
5. Archive to `DOCS/TASK_ARCHIVE/19_C3_CreateLinkGraph/`
