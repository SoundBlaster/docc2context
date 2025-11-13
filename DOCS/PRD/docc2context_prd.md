# DocC2Context CLI – Product Requirements & Execution Plan

## 1. Scope and Intent
| Item | Details |
| --- | --- |
| Objective | Build a cross-platform (Linux + macOS) Swift CLI that converts existing DocC archives or directories into a structured Markdown corpus with DocC-equivalent content and cross-document links, optimized for LLM consumption. |
| Primary Deliverables | 1) Swift command-line executable `docc2context`. 2) Converter pipeline supporting DocC bundle inputs (folder or archive). 3) Markdown output tree preserving hierarchy, metadata, and link graph. 4) Automated tests validating conversion fidelity. |
| Success Criteria | Given a valid DocC bundle/archive, the tool emits Markdown files whose content, metadata, and navigational links mirror the original DocC documentation; CLI offers discoverable help; end-to-end tests pass on Linux and macOS Swift toolchains. |
| Constraints | Swift 5.9+; no proprietary dependencies; must operate offline; output Markdown must be deterministic; adhere to POSIX shell execution for automation. |
| Assumptions | DocC bundle structure follows Apple DocC specification; Swift DocC symbol graphs are available within bundles; filesystem access is unrestricted; LLM agents consume plain Markdown and JSON metadata. |
| External Dependencies | SwiftDocC parsing libraries (DocCKit / SymbolKit), Foundation file APIs, optional compression libraries for .doccarchive extraction. |

## 2. Structured TODO Plan
### Phase A – Project Initialization
| ID | Task | Description | Dependencies | Parallelizable |
| --- | --- | --- | --- | --- |
| A1 | Bootstrap Swift Package | Create SwiftPM package with CLI target, shared library target for conversion logic, and test target. | None | Yes |
| A2 | Define CLI Interface | Specify command options (input path, output path, format flags) using ArgumentParser. | A1 | Yes |
| A3 | Establish DocC Sample Fixtures | Collect or synthesize DocC bundles for testing, stored under `Fixtures/`. | None | Yes |

### Phase B – DocC Intake & Parsing
| ID | Task | Description | Dependencies | Parallelizable |
| --- | --- | --- | --- | --- |
| B1 | Detect Input Type | Implement logic to detect directories vs `.doccarchive` zip and normalize to bundle path. | A1 | Yes |
| B2 | Extract Archive Inputs | If archive provided, extract to temp directory with deterministic paths. | B1 | Yes |
| B3 | Parse DocC Metadata | Load `Info.plist`, `data/documentation`, and symbol graph references. | B1 | Limited |
| B4 | Build Internal Model | Define structs/classes representing articles, tutorials, and references for uniform downstream processing. | B3 | No |

### Phase C – Markdown Generation
| ID | Task | Description | Dependencies | Parallelizable |
| --- | --- | --- | --- | --- |
| C1 | Generate Markdown Files | Convert each DocC page/article into Markdown preserving headings, body text, code listings, media references. | B4 | No |
| C2 | Create Link Graph | Compute cross-links between pages using original DocC reference identifiers and emit link metadata files (JSON). | C1 | Limited |
| C3 | Emit TOC and Index | Produce global index and table-of-contents Markdown enabling navigation. | C2 | Yes |
| C4 | Verify Determinism | Run conversion twice to ensure identical output (hash comparison). | C1 | No |

### Phase D – CLI UX & Validation
| ID | Task | Description | Dependencies | Parallelizable |
| --- | --- | --- | --- | --- |
| D1 | Implement Logging & Progress | Provide structured logging of phases, errors, and success summary. | A2 | Yes |
| D2 | Add Validation Tests | Unit tests for parsing + generation, integration tests converting fixture bundles. | B4, C1 | No |
| D3 | Document Usage | Create README section describing CLI usage, options, and examples. | D1 | Yes |
| D4 | Package Distribution | Ensure `swift build` produces release binary, include install instructions. | D2 | Yes |

## 3. Execution Metadata
| Task ID | Priority | Effort | Required Tools/Libraries | Acceptance Criteria | Verification Method |
| --- | --- | --- | --- | --- | --- |
| A1 | High | 2 pts | SwiftPM | `swift build` succeeds; package contains targets `Docc2ContextCLI`, `Docc2ContextCore`. | CI build log. |
| A2 | High | 1 pt | swift-argument-parser | `docc2context --help` displays documented options. | Snapshot test. |
| A3 | Medium | 1 pt | DocC sample docs | Fixtures exist and accessible via tests. | Repo inspection. |
| B1 | High | 2 pts | Foundation | CLI accepts folder and `.doccarchive` paths and resolves them consistently. | Integration test. |
| B2 | Medium | 2 pts | libarchive / Foundation | Archives extracted to temp dir; cleanup occurs. | Temp dir assertions. |
| B3 | High | 3 pts | DocCKit/SymbolKit | Metadata parsed into native structs; missing fields cause descriptive errors. | Unit tests with corrupted fixtures. |
| B4 | High | 3 pts | Custom models | Internal model contains all article/tutorial/symbol data needed downstream. | Unit tests verifying mapping. |
| C1 | High | 4 pts | Markdown renderer | Markdown output matches DocC HTML structure per fixture. | Golden file comparison. |
| C2 | Medium | 2 pts | Graph utilities | Link graph JSON lists all cross-references; no dangling links. | Graph validation tests. |
| C3 | Medium | 1 pt | Markdown templates | TOC and index contain all generated files with correct links. | Snapshot tests. |
| C4 | Medium | 1 pt | Hash utilities | Two consecutive runs produce identical hashes for same input. | Hash comparison script. |
| D1 | Low | 1 pt | Logging framework | CLI prints progress with log levels. | Manual run transcript. |
| D2 | High | 3 pts | XCTest | Test suite covers parsing + generation; CI run passes. | `swift test`. |
| D3 | Medium | 1 pt | Markdown docs | README section includes usage and examples. | Doc review. |
| D4 | Medium | 1 pt | SwiftPM | Release build instructions verified; binary executes. | `swift build -c release`. |

## 4. Product Requirements Document
### 4.1 Feature Description & Rationale
DocC2Context converts DocC documentation bundles into Markdown corpora so that LLM agents can ingest, search, and cross-reference Apple documentation offline. It ensures parity between DocC content and resulting Markdown, including navigation metadata, enabling improved context windows and automated reasoning over Apple frameworks.

### 4.2 Functional Requirements
1. **Input Handling**
   - Accept command `docc2context <input> --output <dir> [--format markdown]`.
   - Detect `.doccarchive` vs directory and normalize to bundle structure.
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
   - Include unit tests for parser, generator, and CLI option parsing.
   - Provide integration test converting a sample DocC bundle end-to-end.

### 4.3 Non-Functional Requirements
- **Performance:** Convert 10 MB DocC bundle within 10 seconds on modern laptop (M1/M2, 16GB RAM).
- **Scalability:** Handle bundles up to 1 GB by streaming file operations and incremental Markdown writing.
- **Determinism:** Same inputs yield byte-identical outputs.
- **Portability:** Builds on Swift 5.9+ for Linux and macOS without platform-specific patches.
- **Security:** Reject path traversal attempts; sanitize extraction directories; no network access required.
- **Compliance:** Output Markdown uses UTF-8; logs omit sensitive data.

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
