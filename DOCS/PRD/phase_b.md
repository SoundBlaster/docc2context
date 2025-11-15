# Phase B – CLI Contract & Input Validation

**Progress Tracker:** `5/6 tasks complete (83%)`

- [x] **B1 – Specify CLI Interface via Failing Tests** — Completed; archived under `DOCS/TASK_ARCHIVE/02_B1_CLIInterfaceTests/` with XCTest coverage that locks CLI flags, help text, and failure messaging.
- [x] **B2 – Implement Argument Parsing to Satisfy Tests** — Completed; archived under `DOCS/TASK_ARCHIVE/05_B2_ArgumentParsing/` with `swift-argument-parser` wiring + README usage parity.
- [x] **B3 – Detect Input Type** — Completed; archived under `DOCS/TASK_ARCHIVE/07_B3_InputDetection/` with normalization for DocC directories vs `.doccarchive` files plus typed validation errors.
- [x] **B4 – Extract Archive Inputs** — Completed; archived under `DOCS/TASK_ARCHIVE/10_B4_ArchiveExtraction/` where `ArchiveExtractor` delivers hash-derived temp directories, cleanup semantics, and CLI-surfaced errors.
- [x] **B5 – Parse DocC Metadata** — Completed; archived under `DOCS/TASK_ARCHIVE/09_B5_DoccMetadataParsing/` with parser domain models covering Info.plist, render metadata, documentation catalogs, and symbol graph references.
- [ ] **B6 – Build Internal Model**
  - Define Swift structs/classes representing tutorials, articles, symbols, and metadata relationships.
  - Serialize/deserialize the model in tests to guarantee stability for downstream Markdown generation.
  - Capture notes on how the model maps to Phase C generators for easy reference.
