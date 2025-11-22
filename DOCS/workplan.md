# docc2context Workplan

The workplan distills the execution order of the phases defined in [DOCS/PRD/docc2context_prd.md](./PRD/docc2context_prd.md). Use it as the live view of sequencing and ownership when deciding which task to start next.

## Phase A – Quality & Deployment Foundations
- ✅ **A1 Bootstrap Swift Package & CI Skeleton** — establish SwiftPM targets and CI workflows for Linux + macOS. Archived under `DOCS/TASK_ARCHIVE/01_A1_BootstrapSwiftPMCI/`.
- ✅ **A2 Provision TDD Harness** — add XCTest utilities and snapshot helpers so every feature begins with failing tests. Archived under `DOCS/TASK_ARCHIVE/03_A2_TDDHarness/`.
- ✅ **A3 Establish DocC Sample Fixtures** — archived under `DOCS/TASK_ARCHIVE/06_A3_DocCFixtures/`; repository now ships two synthetic DocC bundles + manifest hashes for tutorials/articles.
- ✅ **A4 Define Deployment & Release Gates** — archived under `DOCS/TASK_ARCHIVE/04_A4_ReleaseGates/`; `Scripts/release_gates.sh` now runs `swift test`, determinism hashing, and fixture manifest validation.

## Phase B – CLI Contract & Input Validation
- ✅ **B1 Specify CLI Interface via Failing Tests** — archived under `DOCS/TASK_ARCHIVE/02_B1_CLIInterfaceTests/`; test suite locks CLI arguments, help text, `--force`, and error paths.
- ✅ **B2 Implement Argument Parsing to Satisfy Tests** — archived under `DOCS/TASK_ARCHIVE/05_B2_ArgumentParsing/`; CLI options now run through `Docc2contextCLIOptions` and satisfy the B1 tests.
- ✅ **B3 Detect Input Type** — archived under `DOCS/TASK_ARCHIVE/07_B3_InputDetection/`; detection enum + CLI wiring now normalize DocC directories and `.doccarchive` paths with deterministic error handling.
- ✅ **B4 Extract Archive Inputs** — archived under `DOCS/TASK_ARCHIVE/10_B4_ArchiveExtraction/`; `ArchiveExtractor` now unpacks `.doccarchive` inputs into hash-derived temp directories with cleanup handles validated via fixture-backed tests and release gates.
- ✅ **B5 Parse DocC Metadata** — archived under `DOCS/TASK_ARCHIVE/09_B5_DoccMetadataParsing/`; parser entry points cover Info.plist, render metadata, and symbol graphs.
- ✅ **B6 Build Internal Model** — archived under `DOCS/TASK_ARCHIVE/11_B6_InternalModel/`; `DoccInternalModelBuilder` now emits deterministic tutorial volumes + symbol reference ordering validated by `DoccInternalModelBuilderTests` and `swift test`.
- ✅ **B6 Serialization Coverage** — archived under `DOCS/TASK_ARCHIVE/13_B6_SerializationCoverage/`; deterministic encoder helpers, JSON snapshots, and serialization tests enforce stable `DoccBundleModel` outputs for downstream Markdown work.

## Phase C – Markdown Generation
- ✅ **C1 Author Snapshot Specs for Markdown Output** — golden Markdown fixtures for each DocC entity type. Planning outline archived under `DOCS/TASK_ARCHIVE/14_C1_MarkdownRenderingStrategy/`, tutorial overview + chapter specs live in `DOCS/TASK_ARCHIVE/15_C1_TutorialChapterSnapshot/`, and the umbrella/tactical notes for tutorial + reference article coverage are now archived under `DOCS/TASK_ARCHIVE/16_C1_MarkdownSnapshotSpecs/` and `DOCS/TASK_ARCHIVE/17_C1_ReferenceArticleSnapshot/` after `MarkdownSnapshotSpecsTests` recorded the golden Markdown files.
- ✅ **C2 Generate Markdown Files** — archived under `DOCS/TASK_ARCHIVE/18_C2_GenerateMarkdown/`; the new `MarkdownGenerationPipeline` orchestrates detection, extraction, model building, and Markdown rendering to write deterministic files for tutorial volumes/chapters and reference articles while `Docc2contextCommand` integration tests confirm the CLI logs generation counts and honors `--force`. Validated via `swift test` and the CLI pipeline fixtures.
- ✅ **C3 Create Link Graph** — archived under `DOCS/TASK_ARCHIVE/19_C3_CreateLinkGraph/`; `LinkGraphBuilder` extracts adjacency relationships from `DoccBundleModel` and writes deterministic JSON to `output/linkgraph/adjacency.json`. 7 unit tests + 1 pipeline integration test validate extraction, determinism, and unresolved reference tracking.
- ✅ **C4 Emit TOC and Index** — archived under `DOCS/TASK_ARCHIVE/20_C4_EmitTOCAndIndex/`; planning note captures TOC/index generation requirements plus validation evidence from the latest `swift test` run prior to hand-off to C5.
- ✅ **C5 Verify Determinism** — archived under `DOCS/TASK_ARCHIVE/21_C5_VerifyDeterminism/`; determinism validator, release gates hashing, CI job, and README workflow ensure consecutive conversions hash-identically locally and in CI.

## Phase D – Quality Gates, Packaging, and Documentation
- ✅ **D1 Implement Logging & Progress** — archived under `DOCS/TASK_ARCHIVE/08_D1_StructuredLogging/`; CLI emits deterministic phase lifecycle events and summary counts with tests + release gates enforcing the contract.
- ✅ **D2 Harden Test Coverage** — archived under `DOCS/TASK_ARCHIVE/22_D2_HardenTestCoverage/`; expanded failure-path tests (69 total), introduced `Scripts/enforce_coverage.py`, wired the helper into `Scripts/release_gates.sh` and CI, and raised `Docc2contextCore` line coverage to ≥90% before documentation work.
- ✅ **D3 Document Usage & Testing Workflow** — archived under `DOCS/TASK_ARCHIVE/23_D3_DocumentUsageTestingWorkflow/`; README now documents CLI usage, fixtures, automation, and troubleshooting, plus `Scripts/lint_markdown.py` and `DocumentationGuidanceTests` ensure doc guidance stays enforced locally and in CI.
- ✅ **D4 Package Distribution & Release Automation** — archived under `DOCS/TASK_ARCHIVE/24_D4_PackageDistributionRelease/`; `Scripts/package_release.sh`, associated tests, README docs, and the release workflow only run after `Scripts/release_gates.sh` succeeds so tagged builds publish deterministic Linux/macOS artifacts with hashes.
- ✅ **D4-LNX Linux Release Packaging Matrix** — archived under `DOCS/TASK_ARCHIVE/25_D4-LNX_LinuxReleasePackagingMatrix/`; delivered multi-arch tarballs, `.deb`/`.rpm` packages via `Scripts/build_linux_packages.sh`, release workflow matrix updates, README install snippets, and follow-up notes for apt/dnf hosting + musl builds.
- ✅ **D4-MAC macOS Release Channels** — archived under `DOCS/TASK_ARCHIVE/26_D4-MAC_MacReleaseChannels/`; implemented architecture-aware macOS packaging, deterministic Homebrew formula generation via `Scripts/build_homebrew_formula.py`, macOS install helper (`Scripts/install_macos.sh`), comprehensive codesign/notarization documentation in README, and release workflow enhancements so both arm64 and x86_64 distributions are available to macOS users via Homebrew tap or manual download.

## Tracking Conventions
- Store active task notes inside `DOCS/INPROGRESS/`.
- Capture ready-to-pick tasks plus dependencies in [DOCS/todo.md](./todo.md).
- Archive completed efforts under `DOCS/TASK_ARCHIVE/` and append summary entries to `ARCHIVE_SUMMARY.md`.
