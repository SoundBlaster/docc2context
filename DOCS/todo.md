# docc2context TODO List

Use this list for near-term execution. Each entry maps back to the PRD and [workplan](./workplan.md).

## In Progress
- [ ] **A2** Create XCTest support utilities (temporary directories, fixture loader) and snapshot harness. _Depends on:_ A1. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ Active – scoped in `DOCS/INPROGRESS/A2_TDDHarness.md`.
- [x] **B1** Author failing CLI interface tests describing arguments (`--output`, `--force`, `--format`). _Depends on:_ A2. _Doc:_ PRD §Phase B. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/02_B1_CLIInterfaceTests/`.
- [x] **A1** Bootstrap Swift package with CLI/lib/test targets plus GitHub Actions matrix for Linux/macOS. _Depends on:_ none. _Doc:_ PRD §Phase A. _Owner:_ docc2context agent. _Status:_ Complete – archived under `DOCS/TASK_ARCHIVE/01_A1_BootstrapSwiftPMCI/`.

## Ready to Start
- _None – see In Progress for the current execution queue._

## Under Consideration
- [ ] Collect at least two public DocC bundles for fixtures (SwiftUI Tutorials, SampleKit). Document provenance in `Fixtures/README.md`.
- [ ] Draft release gate checklist covering determinism hash job and fixture integrity verification script.
- [ ] Outline Markdown rendering strategy for tutorials vs articles in preparation for C1 snapshot specs.

## Backlog Ideas
- [ ] Explore incremental conversion to stream Markdown output for very large DocC bundles.
- [ ] Investigate CLI `--filter technology` flag for selective exports once baseline pipeline ships.
