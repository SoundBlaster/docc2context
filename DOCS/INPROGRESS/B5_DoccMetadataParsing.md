# B5 – DocC Metadata Parsing Pipeline

## Objective
Design and implement the metadata parsing layer that ingests normalized DocC bundles and produces strongly typed Swift models for downstream Markdown generation. This addresses PRD Phase B item **B5 Parse DocC Metadata**, ensuring Info.plist, documentation data, tutorials, and symbol graph references are loaded deterministically with descriptive validation errors.

## Reference Materials
- `DOCS/PRD/docc2context_prd.md` — Phase B table (ID B5) plus functional requirements covering DocC parsing.
- `DOCS/PRD/phase_b.md` — acceptance criteria for metadata ingestion and error propagation.
- `DOCS/workplan.md` — confirms B5 follows B3 and can progress in parallel with B4 once bundle normalization exists.
- Existing fixtures inside `Fixtures/` and the manifest added during **A3**.

## Dependencies & Preconditions
- ✅ **B3 Input Detection** ensures metadata parsers receive either directory bundles or (post-B4) extracted archives.
- 🔄 **B4 Archive Extraction** is still in progress but not a strict blocker because B5 can be validated using directory-style fixtures while monitoring B4 for archive-path nuances.
- ✅ **A2/A3** provide the test harness and DocC fixtures needed for parser specs.
- 📌 Need to codify the internal data structures before Markdown tasks begin (prerequisite for B6, C1).

## Test Plan
1. **Info.plist Parsing** — Failing specs that ensure bundle metadata (identifier, display name, locale paths) load into Swift structs and handle missing keys with specific error cases.
2. **Documentation Data Loading** — Tests that parse tutorials/articles JSON and verify locale fallback plus deterministic ordering (using Fixtures/tutorial bundle).
3. **Symbol Graph Reference Mapping** — Ensure symbol graph files referenced in documentation catalog map to model entries; corrupted graphs should raise warnings/errors captured in tests.
4. **Error Propagation** — Corrupted/missing files should throw typed errors that bubble up to the CLI with actionable messages.
5. **Integration Harness** — Compose parser entry point (e.g., `DoccMetadataParser.parse(bundleURL:)`) returning an intermediate model used later by B6.

### Commands
- `swift test --filter MetadataParsingTests`
- `swift test`
- `Scripts/release_gates.sh` prior to archiving the task

## Execution Checklist
- [ ] Author `MetadataParsingTests` describing Info.plist, documentation, and symbol graph scenarios using existing fixtures.
- [ ] Define parser-facing domain models (metadata structs/enums) with validation helpers.
- [ ] Implement parser to satisfy tests, ensuring deterministic ordering and locale handling.
- [ ] Document assumptions + integration notes (README/CLI) if parser requires additional flags or environment setup.
- [ ] Update TODO + ARCHIVE entries once work completes.

## Immediate Next Actions
1. Inspect existing fixtures (`Fixtures/Tutorial.docc`, etc.) to enumerate the metadata files needed for tests.
2. Draft failing tests for Info.plist parsing plus minimal parser interface signature.
3. Evaluate whether SymbolKit/SymbolGraph data needs mocking or if fixtures already contain graphs; plan helper utilities accordingly.

## Coordination Notes
- Sync periodically with the B4 effort so parser input paths align with extracted archive layout (e.g., relative resource locations).
- Ensure any new helper utilities live under `Sources/Docc2contextCore` with mirrored test helpers inside `Tests/Docc2contextCoreTests/Support/`.
