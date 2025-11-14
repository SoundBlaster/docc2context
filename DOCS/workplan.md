# docc2context Workplan

The workplan distills the execution order of the phases defined in [DOCS/PRD/docc2context_prd.md](./PRD/docc2context_prd.md). Use it as the live view of sequencing and ownership when deciding which task to start next.

## Phase A – Quality & Deployment Foundations
- ✅ **A1 Bootstrap Swift Package & CI Skeleton** — establish SwiftPM targets and CI workflows for Linux + macOS. Archived under `DOCS/TASK_ARCHIVE/01_A1_BootstrapSwiftPMCI/`.
- ✅ **A2 Provision TDD Harness** — add XCTest utilities and snapshot helpers so every feature begins with failing tests. Archived under `DOCS/TASK_ARCHIVE/03_A2_TDDHarness/`.
- **A3 Establish DocC Sample Fixtures** — gather DocC bundles under `Fixtures/` covering articles, tutorials, and symbol graphs.
- ✅ **A4 Define Deployment & Release Gates** — archived under `DOCS/TASK_ARCHIVE/04_A4_ReleaseGates/`; `Scripts/release_gates.sh` now runs `swift test`, determinism hashing, and fixture manifest validation.

## Phase B – CLI Contract & Input Validation
- ✅ **B1 Specify CLI Interface via Failing Tests** — archived under `DOCS/TASK_ARCHIVE/02_B1_CLIInterfaceTests/`; test suite locks CLI arguments, help text, `--force`, and error paths.
- **B2 Implement Argument Parsing to Satisfy Tests** — implement CLI options using `swift-argument-parser` until B1 passes.
- **B3 Detect Input Type** — ensure directories vs `.doccarchive` inputs normalize to bundle paths, covered by tests.
- **B4 Extract Archive Inputs** — add deterministic extraction with cleanup validated via fixture-based tests.
- **B5 Parse DocC Metadata** — read Info.plist, tutorials, and symbol graphs into native models.
- **B6 Build Internal Model** — define structs representing DocC pages and references.

## Phase C – Markdown Generation
- **C1 Author Snapshot Specs for Markdown Output** — golden Markdown fixtures for each DocC entity type.
- **C2 Generate Markdown Files** — convert each DocC page into Markdown matching DocC semantics.
- **C3 Create Link Graph** — emit JSON metadata linking pages and references.
- **C4 Emit TOC and Index** — deterministic ordering of navigation files.
- **C5 Verify Determinism** — double-run conversions in CI and compare hashes.

## Phase D – Quality Gates, Packaging, and Documentation
- **D1 Implement Logging & Progress** — structured logging with snapshot tests.
- **D2 Harden Test Coverage** — drive coverage >90% on critical paths before release.
- **D3 Document Usage & Testing Workflow** — README updates for CLI usage, fixtures, and automation.
- **D4 Package Distribution & Release Automation** — release script that builds and publishes binaries only after gates succeed.

## Tracking Conventions
- Store active task notes inside `DOCS/INPROGRESS/`.
- Capture ready-to-pick tasks plus dependencies in [DOCS/todo.md](./todo.md).
- Archive completed efforts under `DOCS/TASK_ARCHIVE/` and append summary entries to `ARCHIVE_SUMMARY.md`.
