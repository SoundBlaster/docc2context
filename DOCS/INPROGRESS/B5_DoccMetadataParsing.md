# B5 – DocC Metadata Parsing Pipeline

## Objective
Design and implement the metadata parsing layer that ingests normalized DocC bundles and produces strongly typed Swift models for downstream Markdown generation. This addresses PRD Phase B item **B5 Parse DocC Metadata**, ensuring Info.plist, documentation data, tutorials, and symbol graph references are loaded deterministically with descriptive validation errors.

## Relevant PRD Paragraphs
- `DOCS/PRD/docc2context_prd.md` — Phase B checklist entry **B5** plus parser acceptance criteria and determinism guarantees.
- `DOCS/PRD/phases.md#phase-b` — outlines validation requirements for DocC metadata ingestion and downstream dependency links.
- `DOCS/workplan.md` — confirms B5 follows B3 and can progress in parallel with B4 once bundle normalization exists.

## First Failing Test to Author
- `MetadataParsingTests.test_infoPlistLoadsBundleMetadata` will load `Fixtures/TutorialCatalog.doccarchive/Info.plist` via `DoccMetadataParser` and assert identifier, display name, technology root, and locales. This test establishes the parser API and expected Info.plist contract before any implementation exists.

## Dependencies & Preconditions
- ✅ **B3 Input Detection** ensures metadata parsers receive either directory bundles or (post-B4) extracted archives.
- 🔄 **B4 Archive Extraction** is still in progress but not a strict blocker because B5 can be validated using directory-style fixtures while monitoring B4 for archive-path nuances.
- ✅ **A2/A3** provide the test harness and DocC fixtures needed for parser specs.
- 📌 Need to codify the internal data structures before Markdown tasks begin (prerequisite for B6, C1).

## Validation Plan
1. **Info.plist Parsing** — Failing specs ensure bundle metadata (identifier, display name, locale paths) load into Swift structs and handle missing keys with specific error cases.
2. **Documentation Data Loading** — Tests parse tutorials/articles JSON and verify locale fallback plus deterministic ordering (using fixtures).
3. **Symbol Graph Reference Mapping** — Tests validate symbol graph references map correctly and surface corrupted graphs via typed errors.
4. **Error Propagation** — Corrupted/missing files throw typed errors that bubble up to the CLI with actionable messages.
5. **Integration Harness** — Compose parser entry point (e.g., `DoccMetadataParser.parse(bundleURL:)`) returning an intermediate model used later by B6.

### Commands
- `swift test --filter MetadataParsingTests`
- `swift test`
- `Scripts/release_gates.sh` prior to archiving the task

### Fixtures & Utilities
- `Fixtures/TutorialCatalog.doccarchive` for tutorial metadata coverage.
- `Fixtures/ArticleReference.doccarchive` for article-only metadata edge cases.
- Existing fixture loader/test temporary directory utilities.

## Execution Checklist
- [x] Review SELECT_NEXT context and confirm B5 is ready to begin.
- [x] Document scope, references, validation strategy, and first failing test in this note.
- [x] Update `DOCS/todo.md` with "In Progress" annotation + link to this plan and failing test reference.
- [x] Scaffold `MetadataParsingTests` with the Info.plist scenario to drive implementation.
- [x] Flesh out additional failing tests for documentation catalogs and symbol graph references.
- [x] Define parser-facing domain models (metadata structs/enums) with validation helpers.
- [x] Implement parser to satisfy tests, ensuring deterministic ordering and locale handling.
- [ ] Document assumptions + integration notes (README/CLI) if parser requires additional flags or environment setup.
- [ ] Update TODO + ARCHIVE entries once work completes.

## Immediate Next Actions
1. ✅ Added `MetadataParsingTests.test_renderMetadataLoadsBundleInformation`, `test_documentationCatalogLoadsTechnologyOverview`, and `test_symbolGraphReferencesLoadFromArticleReferenceBundle` so `metadata.json`, technology catalog JSON, and symbol graphs now drive parser behavior alongside the Info.plist spec.
2. ✅ Introduced typed domain models (`DoccRenderMetadata`, `DoccDocumentationCatalog`, `DoccSymbolReference`) plus validation errors for missing/invalid JSON files.
3. ✅ Implemented parser entry points for render metadata, documentation catalogs, and symbol graph references so downstream Markdown tasks can consume strongly typed data.

### Notes
- Symbol graph references are sorted deterministically by identifier/module to keep CI output stable regardless of filesystem ordering.
- Documentation catalog parsing currently targets the technology root JSON; follow-up integration work will wire tutorial/article nodes once Phase B tasks unblock.

## Blocking Questions / Coordination Notes
- Sync periodically with the B4 effort so parser input paths align with extracted archive layout (e.g., relative resource locations).
- Confirm whether metadata parsing should normalize locale identifiers (`en`, `en-US`) up front or defer until Markdown rendering (impacts test fixtures).
- Ensure any new helper utilities live under `Sources/Docc2contextCore` with mirrored test helpers inside `Tests/Docc2contextCoreTests/Support/`.
