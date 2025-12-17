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
- ✅ **B4 Archive Inputs (No Auto-Extraction)** — `.doccarchive` directories are treated as DocC bundles; `.doccarchive` files are rejected with explicit extraction guidance (see `Docc2contextCLITests.testArchiveInputProvidesExtractionGuidance`). Historical notes about automatic extraction live under `DOCS/TASK_ARCHIVE/10_B4_ArchiveExtraction/` and are superseded by the current contract.
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

## Phase E – Release Infrastructure & End-to-End Validation
- ✅ **E1 Documentation Synchronization & Post-Phase-D Cleanup** — archived under `DOCS/TASK_ARCHIVE/27_E1_DocumentationSync/`; synchronized all phase documents and task tracking across DOCS/ to reflect A–D completion and cataloged follow-up opportunities.
- ✅ **E2 Homebrew Tap Publishing Automation** — archived under `DOCS/TASK_ARCHIVE/28_E2_HomebrewTapPublishing/`; automated Homebrew formula updates via GitHub Actions workflow with dry-run testing, SECRETS documentation, and release template integration.
- ⛔ **E3 CI Signing/Notarization Setup** — BLOCKED pending Apple Developer ID credentials and GitHub secrets provisioning. Documented in `DOCS/INPROGRESS/BLOCKED_E3_SigningNotarization.md`; required to automate macOS notarization for prebuilt binaries.
- ✅ **E4 E2E Release Simulation** — archived under `DOCS/TASK_ARCHIVE/29_E4_E2EReleaseSim/`; added comprehensive release workflow E2E tests that validate Linux/macOS artifact naming, Homebrew formula syntax, README install instructions, release gate enforcement, and checksum generation. Full dry-run CI tag simulation deferred due to timeouts and E3 blocker.

## Phase F – Performance & Enhancements
- ✅ **F1 Incremental Conversion** — archived under `DOCS/TASK_ARCHIVE/30_F1_IncrementalConversion/`; streaming-friendly Markdown generation optimizations reduce intermediate allocations while preserving determinism, backed by profiling helper (`Scripts/profile_memory.sh`) and 4 streaming optimization tests.
- ✅ **F2 Technology Filter Flag** — archived under `DOCS/TASK_ARCHIVE/31_F2_TechnologyFilterFlag/`; added repeatable `--technology <name>` flag, piped module filtering into `MarkdownGenerationPipeline`, preserved tutorials/articles output, expanded summary counts with `symbolCount`, refreshed README, and landed 8 tests covering CLI parsing + deterministic filtered exports.
- ✅ **F3 Performance Benchmark Harness** — archived under `DOCS/TASK_ARCHIVE/43_F3_PerformanceBenchmarkHarness/`; shipped `PerformanceBenchmarkHarness`, `BenchmarkFixtureBuilder`, and the `docc2context-benchmark` executable with synthetic bundle inflation options, metrics JSON export, and documentation updates validated by `swift test --disable-sandbox` (126 tests, 9 skipped, 0 failures).
- ✅ **F3.1 Performance Regression CI** — archived under `DOCS/TASK_ARCHIVE/44_F3.1_PerformanceRegressionCI/`; added baseline/tolerance comparison via `BenchmarkComparator`, stored deterministic baseline metrics, and introduced the opt-in `Performance Benchmark` workflow plus CLI `--fail-on-regression` flag with accompanying tests.
- 🟡 **F4 Dogfood DocC Fixture from Sources** — Add real DocC documentation in `Sources/` and commit a generated `.doccarchive` (via `swift package generate-documentation`) under `Fixtures/` as a realistic parser/renderer fixture with provenance notes and deterministic snapshot coverage. (Tracked in PRD §5 “Post-MVP Enhancements”; generation guidance exists under `DOCS/TASK_ARCHIVE/42_S0_DocCGenerationNotes/`.)
- ✅ **H2 musl Build Support** — archived under `DOCS/TASK_ARCHIVE/33_H2_muslBuildSupport/`; integrated Swift Static Linux SDK into the Linux matrix to publish musl tarball/DEB/RPM variants, documented installation guidance in README and release template, and validated determinism parity with glibc builds across fixtures.
- ✅ **H3 Additional Package Manager Integration** — archived under `DOCS/TASK_ARCHIVE/34_H3_AURPackageIntegration/`; added the Arch Linux AUR PKGBUILD generator (`Scripts/build_aur_pkgbuild.py`), validated it with `AurPkgbuildScriptTests`, and documented `makepkg` usage in README while keeping H1 apt/dnf repository hosting deferred.
- ✅ **G0 Test Debt Cleanup** — archived under `DOCS/TASK_ARCHIVE/32_G0_TestDebtCleanup/`; eliminated all `swift test` warnings by fixing XCTSkip usage with `throw` keyword and reorganizing platform-specific test code via preprocessor directives. All 91 tests pass with zero warnings; coverage gate (90.43%) and determinism gates verified.

## Phase H – Repository Distribution Hardening
- ⛔ **H1 APT/DNF Repository Hosting** — blocked by external service credentials and signing keys; tracked in `DOCS/INPROGRESS/BLOCKED_H1_APTDNFRepositoryHosting.md` while Linux users rely on manual downloads/Homebrew/DEB/RPM artifacts.
- 🟡 **H4 Repository Validation Harness (Planning)** — designing repository health checks and offline validation gates pending hosting access. Notes live in `DOCS/INPROGRESS/H4_RepoValidationHarness.md`; implementation is archived in `DOCS/TASK_ARCHIVE/40_H4_RepositoryValidationHarnessImplementation/`.
- 🟡 **H5 Repository Metadata Fixtures & Offline Harness (Planning)** — outlines fixture schema, signing approaches, and offline harness scaffolding under `DOCS/INPROGRESS/H5_RepositoryMetadataFixtures.md`.
- ✅ **H5 Repository Metadata Fixtures Implementation** — archived under `DOCS/TASK_ARCHIVE/39_H5_RepositoryMetadataFixturesImplementation/`; delivered deterministic apt/dnf metadata fixtures, a manifest-driven validator, XCTests for tamper detection, and documentation for fixture usage.

## Tracking Conventions
- Store active task notes inside `DOCS/INPROGRESS/`.
- Capture ready-to-pick tasks plus dependencies in [DOCS/todo.md](./todo.md).
- Archive completed efforts under `DOCS/TASK_ARCHIVE/` and append summary entries to `ARCHIVE_SUMMARY.md`.
- DocC generation workflow guidance now lives in `DOCS/TASK_ARCHIVE/42_S0_DocCGenerationNotes/` for future snapshot and fixture
 planning reference.
