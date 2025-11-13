# Phase C – Markdown Generation

**Progress Tracker:** `0/5 tasks complete (0%)`

- [ ] **C1 – Author Snapshot Specs for Markdown Output**
  - Produce golden Markdown fixtures for each DocC entity (tutorial, article, symbol detail, index entry).
  - Store fixtures alongside DocC inputs with naming conventions for deterministic diffing.
  - Document how to refresh snapshots when intentional changes occur.
- [ ] **C2 – Generate Markdown Files**
  - Implement renderer translating internal model objects into Markdown that mirrors DocC structure.
  - Respect headings, body content, callouts, images, and code listings with stable identifiers.
  - Keep snapshot tests from C1 green as implementation evolves.
- [ ] **C3 – Create Link Graph**
  - Build cross-document link graph leveraging DocC identifiers and relationships captured in Phase B.
  - Emit JSON/Markdown metadata describing adjacency and unresolved references for debugging.
  - Validate using adjacency-matrix tests ensuring no dangling links remain.
- [ ] **C4 – Emit TOC and Index**
  - Generate deterministic table-of-contents and index Markdown with navigation-friendly ordering.
  - Include counts of tutorials/articles/symbols to help QA coverage.
  - Backed by snapshot tests verifying ordering and formatting.
- [ ] **C5 – Verify Determinism**
  - Add CI job executing conversion twice and hashing outputs to confirm byte-identical results.
  - Expose script/command for developers to rerun determinism locally before PRs.
  - Log summary of differences when determinism fails to speed up debugging.
