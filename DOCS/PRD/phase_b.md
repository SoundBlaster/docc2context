# Phase B – CLI Contract & Input Validation

**Progress Tracker:** `6/6 tasks complete (100%)`

- [x] **B1 – Specify CLI Interface via Failing Tests** — Completed; archived under `DOCS/TASK_ARCHIVE/02_B1_CLIInterfaceTests/` with XCTest coverage that locks CLI flags, help text, and failure messaging.
- [x] **B2 – Implement Argument Parsing to Satisfy Tests** — Completed; archived under `DOCS/TASK_ARCHIVE/05_B2_ArgumentParsing/` with `swift-argument-parser` wiring + README usage parity.
- [x] **B3 – Detect Input Type** — Completed; archived under `DOCS/TASK_ARCHIVE/07_B3_InputDetection/` with normalization for DocC directories vs `.doccarchive` files plus typed validation errors.
- [x] **B4 – Archive Inputs (No Auto-Extraction)** — Completed; `.doccarchive` directories are treated as DocC bundles. If a `.doccarchive` file is provided, the CLI fails with extraction guidance (see `Docc2contextCLITests.testArchiveInputProvidesExtractionGuidance`). Historical notes about automatic extraction live under `DOCS/TASK_ARCHIVE/10_B4_ArchiveExtraction/` and are superseded by the current contract.
- [x] **B5 – Parse DocC Metadata** — Completed; archived under `DOCS/TASK_ARCHIVE/09_B5_DoccMetadataParsing/` with parser domain models covering Info.plist, render metadata, documentation catalogs, and symbol graph references.
- [x] **B6 – Build Internal Model** — Completed; archived under `DOCS/TASK_ARCHIVE/11_B6_InternalModel/` (model builder + struct definitions) and `DOCS/TASK_ARCHIVE/13_B6_SerializationCoverage/` (deterministic JSON encoder helpers, fixture-backed serialization tests, and recorded snapshots for downstream Markdown work).
