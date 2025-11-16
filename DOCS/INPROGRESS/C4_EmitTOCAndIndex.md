# C4 – Emit TOC and Index (Cycle 2 Selection)

## Overview
Generate deterministic table-of-contents and index Markdown with navigation-friendly ordering. Include counts of tutorials/articles/symbols to help QA coverage. Backed by snapshot tests verifying ordering and formatting.

## Objective
Complete C4 task as part of cyclic execution workflow:
1. Author failing TOC/index snapshot tests
2. Implement TOC and index generators using link graph and bundle model
3. Validate ordering is deterministic and format matches specs
4. Verify integration with pipeline

## PRD References
- **Phase C, Task C4:** Emit TOC and Index — deterministic ordering of navigation files.
- **Acceptance Criteria:**
  - TOC generated with tutorial volumes, chapters, and articles
  - Index generated with symbols and references
  - Deterministic ordering maintained
  - Snapshot tests validate content and ordering
  - Tests pass locally and in CI

## Dependencies
- ✅ Phase B – All CLI/validation tasks (complete)
- ✅ Phase C1 – Markdown snapshot specs (complete)
- ✅ Phase C2 – Markdown generation (complete)
- ✅ Phase C3 – Link graph (complete)

## Test Plan
1. **TOC Tests**:
   - Test TOC generation from bundle model
   - Test ordering of tutorial volumes, chapters, articles
   - Test determinism (same input = same TOC twice)
   - Snapshot test TOC Markdown output

2. **Index Tests**:
   - Test index generation from symbol references
   - Test ordering by symbol identifier
   - Test references grouped by module/kind
   - Snapshot test index Markdown output

3. **Integration Tests**:
   - Test pipeline writes TOC file to markdown/toc.md
   - Test pipeline writes index file to markdown/index.md
   - Test counts match actual content

## Implementation Scope
- Create `TableOfContents` model with deterministic ordering
- Create `IndexGenerator` to build symbol reference index
- Wire into `MarkdownGenerationPipeline`
- Write TOC to `output/markdown/toc.md`
- Write index to `output/markdown/index.md`
- Update pipeline to include file counts in Summary

## Success Metrics
- ✅ TOC and index generated deterministically
- ✅ Snapshot tests pass
- ✅ No regressions in existing tests
- ✅ `swift test` passes
- ✅ Ready for ARCHIVE and C5 selection

## Status
Created 2025-11-17 during Cycle 2 (SELECT_NEXT phase)
