# docc2context TODO List

Use this list for near-term execution. Each entry maps back to the PRD and [workplan](./workplan.md).

## In Progress
- [ ] **C1 Markdown Rendering Strategy Outline** Define the snapshot/fixture scope for tutorials vs. articles so Markdown generation tasks have clear specs. _Depends on:_ B6 internal model + serialization readiness. _Doc:_ PRD §Phase C, workplan §Phase C. _Owner:_ docc2context agent. _Status:_ In Progress – drafting outline + required fixtures/tests before implementing generators.
- [ ] **C1 Markdown Snapshot Specs** Author failing Markdown snapshot tests plus fixture layout covering tutorial volumes, chapters, and articles before renderer code begins. _Depends on:_ B6 internal model + serialization readiness, C1 outline. _Doc:_ PRD §Phase C, workplan §Phase C. _Owner:_ docc2context agent. _Status:_ In Progress – defining snapshot directory structure, placeholder tests, and remaining open questions inside `DOCS/INPROGRESS/C1_MarkdownSnapshotSpecs.md`.

## Completed
- [x] **B6 Serialization Coverage** Add JSON serialization + determinism tests for `DoccBundleModel` and tutorial volumes. _Depends on:_ B6. _Doc:_ PRD §Phase B acceptance criteria. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/13_B6_SerializationCoverage/`; deterministic encoder helpers, JSON snapshots, and `DoccInternalModelSerializationTests` guard internal model serialization.
- [x] **B6 Documentation Update** Capture the internal model mapping + tutorial ordering guarantees inside `README.md` and developer docs. _Depends on:_ B6. _Doc:_ PRD §Phase B (documentation readiness). _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/12_B6_DocumentationUpdate/`; README section + `InternalModelDocumentationTests` enforce the contract.
- [x] **A2** Create XCTest support utilities (temporary directories, fixture loader) and snapshot harness. _Depends on:_ A1. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/03_A2_TDDHarness/`.
- [x] **A3** Establish DocC sample fixtures (tutorial-focused + API/article bundle) under `Fixtures/` with provenance manifest. _Depends on:_ A2. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/06_A3_DocCFixtures/`; fixtures + manifest hashes committed.
- [x] **A4** Define deployment & release gates (determinism hash, fixture integrity verification script, `swift test` guard). _Depends on:_ A1. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/04_A4_ReleaseGates/`; `Scripts/release_gates.sh` now runs tests, determinism hashes, and fixture validation.
- [x] **B1** Author failing CLI interface tests describing arguments (`--output`, `--force`, `--format`). _Depends on:_ A2. _Doc:_ PRD §Phase B. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/02_B1_CLIInterfaceTests/`.
- [x] **B2** Implement argument parsing to satisfy CLI interface tests using `swift-argument-parser`. _Depends on:_ B1. _Doc:_ PRD §Phase B. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/05_B2_ArgumentParsing/`; `swift test` confirms the CLI contract enforced by `Docc2contextCLIOptions`.
- [x] **B3** Detect input type for directories vs `.doccarchive` inputs so downstream parsing always receives normalized bundle paths. _Depends on:_ B2. _Doc:_ PRD §Phase B. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/07_B3_InputDetection/`; detection enum + CLI wiring validated via `swift test --filter InputDetectionTests` and the release gates script.
- [x] **D1** Implement logging & progress instrumentation so the CLI reports detection/extraction/generation phases with snapshot-tested structure. _Depends on:_ B2. _Doc:_ PRD §Phase D. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/08_D1_StructuredLogging/`; logging facade + CLI integration validated via `swift test --filter LoggingTests` and release gates.
- [x] **A1** Bootstrap Swift package with CLI/lib/test targets plus GitHub Actions matrix for Linux/macOS. _Depends on:_ none. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/01_A1_BootstrapSwiftPMCI/`.
- [x] **B4** Extract archive inputs into deterministic temporary directories with cleanup validation. _Depends on:_ B3. _Doc:_ PRD §Phase B. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/10_B4_ArchiveExtraction/`; `ArchiveExtractor` + CLI wiring validated via `swift test --filter ArchiveExtractionTests`, full `swift test`, and `Scripts/release_gates.sh`.
- [x] **B5** Parse DocC metadata (Info.plist, documentation data, symbol graphs) into native models with fixture-driven failure coverage. _Depends on:_ B3. _Doc:_ PRD §Phase B. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/09_B5_DoccMetadataParsing/`; parser entry points + README integration notes validated by `MetadataParsingTests` and release gates.
- [x] **B6** Build internal DocC model to bridge parsed metadata and future Markdown generation. _Depends on:_ B5. _Doc:_ PRD §Phase B; `PRD/phase_b.md`. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/11_B6_InternalModel/`; `DoccInternalModelBuilder` emits deterministic bundle models validated via `DoccInternalModelBuilderTests.test_buildsTutorialVolumeOrderingFromCatalogFixture` and `swift test`.

## Ready to Start
- _None – tasks promoted to "In Progress" once documentation work kicked off._

## Under Consideration
- _None – waiting on new proposals once C1 outline lands._

## Backlog Ideas
- [ ] Explore incremental conversion to stream Markdown output for very large DocC bundles.
- [ ] Investigate CLI `--filter technology` flag for selective exports once baseline pipeline ships.
