# docc2context TODO List

Use this list for near-term execution. Each entry maps back to the PRD and [workplan](./workplan.md).

## In Progress
- [x] **A2** Create XCTest support utilities (temporary directories, fixture loader) and snapshot harness. _Depends on:_ A1. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/03_A2_TDDHarness/`.
- [ ] **A3** Establish DocC sample fixtures (tutorial-focused + API/article bundle) under `Fixtures/` with provenance manifest. _Depends on:_ A2. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ In Progress – kickoff + validation plan captured in `DOCS/INPROGRESS/A3_DocCFixtures.md`.
- [x] **A4** Define deployment & release gates (determinism hash, fixture integrity verification script, `swift test` guard). _Depends on:_ A1. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/04_A4_ReleaseGates/`; `Scripts/release_gates.sh` now runs tests, determinism hashes, and fixture validation.
- [x] **B1** Author failing CLI interface tests describing arguments (`--output`, `--force`, `--format`). _Depends on:_ A2. _Doc:_ PRD §Phase B. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/02_B1_CLIInterfaceTests/`.
- [ ] **B2** Implement argument parsing to satisfy CLI interface tests using `swift-argument-parser`. _Depends on:_ B1. _Doc:_ PRD §Phase B. _Owner:_ docc2context agent. _Status:_ Newly selected – plan captured in `DOCS/INPROGRESS/B2_ArgumentParsing.md`.
- [x] **A1** Bootstrap Swift package with CLI/lib/test targets plus GitHub Actions matrix for Linux/macOS. _Depends on:_ none. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/01_A1_BootstrapSwiftPMCI/`.

## Ready to Start
- _None – see In Progress for the current execution queue._

## Under Consideration
- [ ] Outline Markdown rendering strategy for tutorials vs articles in preparation for C1 snapshot specs.

## Backlog Ideas
- [ ] Explore incremental conversion to stream Markdown output for very large DocC bundles.
- [ ] Investigate CLI `--filter technology` flag for selective exports once baseline pipeline ships.
