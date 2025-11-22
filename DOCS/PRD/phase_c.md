# Phase C – Markdown Generation

**Progress Tracker:** `5/5 tasks complete (100%)`

- [x] **C1 – Author Snapshot Specs for Markdown Output** (Archived under `DOCS/TASK_ARCHIVE/14_C1_MarkdownRenderingStrategy/`, `15_C1_TutorialChapterSnapshot/`, `16_C1_MarkdownSnapshotSpecs/`, and `17_C1_ReferenceArticleSnapshot/`).
  - Produce golden Markdown fixtures for each DocC entity (tutorial, article, symbol detail, index entry).
  - Store fixtures alongside DocC inputs with naming conventions for deterministic diffing.
  - Document how to refresh snapshots when intentional changes occur.
- [x] **C2 – Generate Markdown Files** (Archived under `DOCS/TASK_ARCHIVE/18_C2_GenerateMarkdown/`).
  - Implement renderer translating internal model objects into Markdown that mirrors DocC structure.
  - Respect headings, body content, callouts, images, and code listings with stable identifiers.
  - Keep snapshot tests from C1 green as implementation evolves.
- [x] **C3 – Create Link Graph** (Archived under `DOCS/TASK_ARCHIVE/19_C3_CreateLinkGraph/`).
  - Build cross-document link graph leveraging DocC identifiers and relationships captured in Phase B.
  - Emit JSON/Markdown metadata describing adjacency and unresolved references for debugging.
  - Validate using adjacency-matrix tests ensuring no dangling links remain.
- [x] **C4 – Emit TOC and Index** (Archived under `DOCS/TASK_ARCHIVE/20_C4_EmitTOCAndIndex/`).
  - Generate deterministic table-of-contents and index Markdown with navigation-friendly ordering.
  - Include counts of tutorials/articles/symbols to help QA coverage.
  - Backed by snapshot tests verifying ordering and formatting.
- [x] **C5 – Verify Determinism** (Archived on 2025-11-16).
  - Add CI job executing conversion twice and hashing outputs to confirm byte-identical results.
  - Expose script/command for developers to rerun determinism locally before PRs.
  - Log summary of differences when determinism fails to speed up debugging.
