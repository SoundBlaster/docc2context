# DocC2Context CLI – Product Requirements & Execution Plan

## 1. Scope and Intent
| Item | Details |
| --- | --- |
| Objective | Build a cross-platform (Linux + macOS) Swift CLI that converts existing DocC archives or directories into a structured Markdown corpus with DocC-equivalent content and cross-document links, optimized for LLM consumption. |
| Primary Deliverables | 1) Swift command-line executable `docc2context`. 2) Converter pipeline supporting DocC bundle inputs (folder or archive). 3) Markdown output tree preserving hierarchy, metadata, and link graph. 4) Automated CI + TDD harness (fixtures, snapshot specs, determinism gates) validating conversion fidelity. |
| Success Criteria | Given a valid DocC bundle/archive, the tool emits Markdown files whose content, metadata, and navigational links mirror the original DocC documentation; CLI offers discoverable help; quality gates (tests, determinism checks, release scripts) exist before feature code merges and pass on Linux and macOS Swift toolchains. |
| Constraints | Swift 5.9+; no proprietary dependencies; must operate offline; output Markdown must be deterministic; adhere to POSIX shell execution for automation. |
| Assumptions | DocC bundle structure follows Apple DocC specification; Swift DocC symbol graphs are available within bundles; filesystem access is unrestricted; LLM agents consume plain Markdown and JSON metadata. |
| External Dependencies | SwiftDocC parsing libraries (DocCKit / SymbolKit), Foundation file APIs. `.doccarchive` inputs are treated as directories produced by DocC; if a user provides a `.doccarchive` file, the CLI emits extraction guidance. |

## 2. Structured TODO Plan
### Phase A – Quality & Deployment Foundations
| ID | Task | Description | Dependencies | Parallelizable |
| --- | --- | --- | --- | --- |
| A1 | Bootstrap Swift Package & CI Skeleton | Create SwiftPM package with CLI target, shared library target, and XCTest target; configure GitHub Actions/Swift CI pipeline executing `swift test` on Linux + macOS. | None | Limited |
| A2 | Provision TDD Harness | Set up XCTest utilities, snapshot testing helpers, and golden-file comparison utilities to drive conversion logic via tests-first iterations. | A1 | No |
| A3 | Establish DocC Sample Fixtures | Collect or synthesize DocC bundles for testing, stored under `Fixtures/`, covering tutorials, articles, and symbol-rich bundles. | A2 | Yes |
| A4 | Define Deployment & Release Gates | Document release checklist (tests, lint, determinism checks) and add scripts to validate artifacts before packaging. | A1 | Yes |

### Phase B – CLI Contract & Input Validation (Test-Driven)
| ID | Task | Description | Dependencies | Parallelizable |
| --- | --- | --- | --- | --- |
| B1 | Specify CLI Interface via Failing Tests | Capture expected CLI arguments, flags, and error outputs through XCTest cases before implementation. | A2 | No |
| B2 | Implement Argument Parsing to Satisfy Tests | Use swift-argument-parser to meet behaviors defined in B1 tests. | B1 | No |
| B3 | Detect Input Type | Detect DocC bundle directories (including `.doccarchive` directories) and reject `.doccarchive` *files* with actionable extraction guidance. | B2 | Limited |
| B4 | Archive Inputs (No Auto-Extraction) | `.doccarchive` directories are treated as DocC bundles. If a `.doccarchive` file is provided, fail with explicit guidance to extract it before converting. | B3 | Yes |
| B5 | Parse DocC Metadata | Load `Info.plist`, documentation data, and symbol graph references guided by fixture-based tests. | B3 | Limited |
| B6 | Build Internal Model | Define structs/classes representing articles, tutorials, and references, red-green-refactor style using model-focused tests. | B5 | No |

### Phase C – Markdown Generation (Red-Green-Refactor)
| ID | Task | Description | Dependencies | Parallelizable |
| --- | --- | --- | --- | --- |
| C1 | Author Snapshot Specs for Markdown Output | Define golden Markdown fixtures per DocC page type to drive generator implementation. | B6 | No |
| C2 | Generate Markdown Files | Convert each DocC page/article into Markdown preserving headings, body text, code listings, and media references until snapshot tests pass. | C1 | No |
| C3 | Create Link Graph | Compute cross-links between pages using original DocC reference identifiers and emit link metadata files (JSON), validated via adjacency-matrix tests. | C2 | Limited |
| C4 | Emit TOC and Index | Produce global index and TOC Markdown enabling navigation, with tests comparing deterministic ordering. | C3 | Yes |
| C5 | Verify Determinism | Run conversion twice in CI to ensure identical output (hash comparison) and gate release on success. | C2 | No |

### Phase D – Quality Gates, Packaging, and Documentation
| ID | Task | Description | Dependencies | Parallelizable |
| --- | --- | --- | --- | --- |
| D1 | Implement Logging & Progress | Provide structured logging of phases, errors, and success summary covered by log snapshot tests. | B2 | Yes |
| D2 | Harden Test Coverage | Expand unit + integration tests (including determinism + failure-path tests) ensuring >90% critical-path coverage before feature freeze. | C5 | No |
| D3 | Document Usage & Testing Workflow | Update README with CLI usage plus explicit instructions for running tests, fixtures, and release scripts. | D2 | Yes |
| D4 | Package Distribution & Release Automation | Ensure `swift build` produces release binary, run release gate script, and publish artifacts conditioned on all tests + quality checks passing. | D3 | Yes |
| D4-LNX | Ship Linux Release Matrix | Produce architecture-specific tarballs (e.g., `docc2context-<version>-linux-<arch>.tar.gz`) and optional `.deb`/`.rpm` packages so Linux users can install via archives or apt/dnf repositories; document install commands and signing expectations. | D4 | Limited |
| D4-MAC | Ship macOS Release Matrix | Provide Homebrew formula/tap plus standalone tarballs per architecture, optionally codesigned + notarized, with README install scripts so macOS users can install via `brew` or manual download. | D4 | Limited |

## 3. Execution Metadata
| Task ID | Priority | Effort | Required Tools/Libraries | Acceptance Criteria | Verification Method |
| --- | --- | --- | --- | --- | --- |
| A1 | High | 3 pts | SwiftPM, GitHub Actions | Swift package + CI workflow run `swift test` on pushes for Linux/macOS. | CI matrix succeeds on scaffold commit. |
| A2 | High | 2 pts | XCTest, SnapshotTesting | Shared test harness utilities compiled and reusable, enabling failing tests before feature code. | Unit tests referencing harness pass. |
| A3 | High | 2 pts | DocC sample docs | Fixture bundles stored under `Fixtures/` with metadata manifest; accessible from tests. | Tests load fixtures without disk errors. |
| A4 | Medium | 1 pt | Bash, Swift scripts | Release gate script enforces lint, determinism, and test pass before tagging. | Script exits non-zero when gate violated. |
| B1 | High | 1 pt | XCTest | CLI spec tests cover all args and failure cases (red tests). | Tests initially fail then pass post-impl. |
| B2 | High | 2 pts | swift-argument-parser | CLI options match spec; help text snapshot passes. | `swift test` CLI suite. |
| B3 | High | 2 pts | Foundation | Input detection handles directories, archives, invalid paths per tests. | Unit tests + fixture permutations. |
| B4 | Medium | 2 pts | libarchive / Foundation | Archive extraction deterministic and cleaned up; tests verify temp paths. | XCTest with hashed outputs. |
| B5 | High | 3 pts | DocCKit/SymbolKit | Metadata parsed into native structs; corrupted fixture tests produce descriptive errors. | Parser test suite. |
| B6 | High | 3 pts | Custom models | Internal model covers articles/tutorials/symbols validated via TDD cycle. | Model serialization tests. |
| C1 | High | 2 pts | SnapshotTesting | Golden Markdown specs exist for each DocC entity type. | Snapshot fixtures stored + referenced. |
| C2 | High | 4 pts | Markdown renderer | Markdown output matches DocC layout; snapshot diffs clean. | Snapshot comparison + `swift test`. |
| C3 | Medium | 2 pts | Graph utilities | Link graph JSON has full coverage; adjacency tests show no dangling nodes. | Graph validation tests. |
| C4 | Medium | 1 pt | Markdown templates | TOC/index generated deterministically verified by tests. | Snapshot tests. |
| C5 | Medium | 1 pt | Hash utilities | Consecutive runs produce identical hashes enforced in CI. | Hash comparison job in CI. |
| D1 | Low | 1 pt | Logging framework | Structured logs validated via log snapshot tests. | XCTest log fixtures. |
| D2 | High | 3 pts | XCTest, coverage tooling | Critical paths maintain >90% coverage threshold enforced via CI badge. | Coverage report uploaded + checked. |
| D3 | Medium | 1 pt | Markdown docs | README documents CLI + testing workflow; doc lints pass. | Markdown lint + review. |
| D4 | Medium | 2 pts | SwiftPM, release scripts | Release pipeline builds, archives, and signs binaries only after gates succeed. | `swift build -c release` + gate script logs. |
| D4-LNX | Medium | 2 pts | SwiftPM, fpm/nfpm, GPG | Release job emits tarballs + `.deb`/`.rpm` artifacts with predictable names + SHA256, README installation docs, and optional GPG signatures. | CI artifact list + README install snippet + package install smoke test. |
| D4-MAC | Medium | 2 pts | SwiftPM, Homebrew tap, codesign | GitHub release hosts macOS tarballs, Homebrew formula taps succeed on arm64/x86_64, and notarization/codesign steps documented or automated. | `brew install` test from tap + notarization log + README script. |

## 4. Product Requirements Document
### 4.1 Feature Description & Rationale
DocC2Context converts DocC documentation bundles into Markdown corpora so that LLM agents can ingest, search, and cross-reference Apple documentation offline. It ensures parity between DocC content and resulting Markdown, including navigation metadata, enabling improved context windows and automated reasoning over Apple frameworks.

### 4.2 Functional Requirements
1. **Input Handling**
   - Accept command `docc2context <input> --output <dir> [--format markdown]`.
   - Accept DocC bundle directories, including `.doccarchive` directories produced by DocC.
   - If a `.doccarchive` file is provided, fail with explicit extraction guidance.
   - Fail with explicit error if DocC manifest missing.
2. **DocC Parsing**
   - Read metadata (`Info.plist`), documentation articles, tutorials, technology catalog, and symbol graphs.
   - Resolve localized content; default to base locale.
3. **Markdown Generation**
   - Produce Markdown per DocC page with identical headings, text blocks, code, callouts, and images (images referenced relatively).
   - Generate cross-link references and index pages.
   - Output deterministic file names derived from DocC identifiers.
4. **CLI Experience**
   - Provide `--help`, `--version`, verbosity flags, and dry-run mode.
   - Exit codes: `0` success, non-zero for validation/parsing/output errors.
5. **Testing & Validation**
   - Practice red-green-refactor: write failing tests for each CLI and conversion behavior before implementing production code.
   - Include unit tests for parser, generator, CLI option parsing, and logging flows.
   - Provide integration test converting a sample DocC bundle end-to-end plus determinism regression tests invoked in CI.

### 4.3 Non-Functional Requirements
- **Performance:** Convert 10 MB DocC bundle within 10 seconds on modern laptop (M1/M2, 16GB RAM).
- **Scalability:** Handle bundles up to 1 GB by streaming file operations and incremental Markdown writing.
- **Determinism:** Same inputs yield byte-identical outputs.
- **Portability:** Builds on Swift 5.9+ for Linux and macOS without platform-specific patches.
- **Security:** Reject path traversal attempts; sanitize extraction directories; no network access required.
- **Compliance:** Output Markdown uses UTF-8; logs omit sensitive data.
- **Quality Gates:** CI must run `swift test`, determinism checks, and coverage verification before packaging artifacts; releases blocked until gates succeed.

### 4.4 User Interaction Flow
1. User installs tool via SwiftPM build or binary download.
2. User runs `docc2context /path/MyDocs.doccarchive --output ./docs-md`.
3. Tool logs detection, extraction, parsing, generation phases with progress.
4. On completion, CLI prints summary with counts of pages, links, and output location.
5. User navigates Markdown output (TOC/index) for downstream ingestion.

### 4.5 Edge Cases & Failure Scenarios
- **Invalid Archive:** If archive missing DocC manifest, abort with `InvalidDocCBundle` error code and descriptive message.
- **Corrupted Symbol Graphs:** Skip affected symbols but continue processing, logging warnings and summarizing skipped items.
- **Output Directory Exists:** Optionally `--force` to overwrite; default is to fail to prevent data loss.
- **Insufficient Disk Space:** Detect write failures and emit actionable error suggesting cleanup.
- **Locale Mismatch:** If requested locale missing, fall back to base locale with warning.
- **Large Media Assets:** Copy or reference assets without loading entire files into memory; handle missing assets with warnings.

### 4.6 Release Packaging & Distribution Requirements
To close out Phase D, the release automation must ship documented distribution channels for Linux and macOS so contributors and users can install the CLI without rebuilding from source.

1. **Baseline Strategy (All Platforms)**
   - Release pipeline emits a single statically (or mostly statically) linked binary per target architecture and uploads archives named `docc2context-<version>-<os>-<arch>.tar.gz` to GitHub Releases alongside SHA256 sums and optional GPG signatures.
   - Tags follow semver (`vX.Y.Z`) and are treated as the source of truth for all downstream package managers.
   - README `Installation` section covers curl/tar instructions plus package manager snippets so users can bootstrap quickly.
2. **Linux Packaging (D4-LNX)**
   - Provide minimal tarball downloads plus advanced packages: `.deb` and `.rpm` built via `fpm`/`nfpm` (or equivalent) that install the binary under `/usr/local/bin`.
   - Document manual install commands (`curl -L ... | tar xz` + `sudo mv`), and publish `dpkg -i`/`dnf install` snippets that point at the release URLs.
   - Capture follow-up for hosting APT/YUM repos (e.g., Cloudsmith/PackageCloud) once signed packages prove useful; track auto-updates via `apt upgrade`/`dnf upgrade` in stretch goals.
   - Explore static `musl` builds for universal compatibility on glibc-diverse distros.
3. **macOS Packaging (D4-MAC)**
   - Maintain a Homebrew tap (or upstream to `homebrew-core`) whose formula points at the versioned tarballs for both `arm64` and `x86_64`; include `test do` clause that runs `docc2context --version`.
   - Offer manual install path mirroring Linux instructions with `/usr/local/bin` or `/opt/homebrew/bin` destinations, plus a one-line install script option.
   - Document codesigning (`codesign --options runtime`) and notarization (`notarytool submit`, `stapler staple`) steps for prebuilt binaries so Gatekeeper trust warnings are minimized, even if Homebrew rebuilds from source.
   - Call out when notarized/signature artifacts are required (e.g., distributing prebuilt bottles) vs optional for source-installs.
