# F2 Technology Filter Flag — Planning Note

## 📋 Task Overview
**Task ID**: F2  
**Title**: Technology filter flag for selective exports  
**Objective**: Assess and plan a CLI flag (e.g., `--filter technology <name>`) that restricts DocC bundle conversion to specific technologies or documentation subsets while preserving determinism, snapshot parity, and pipeline ergonomics.

## 🔎 Current Context
- All Phase A–D deliverables are archived; E3 remains externally blocked, leaving headroom for targeted enhancements (Phase F).  
- CLI argument parsing and validation (B1–B4) plus link graph/TOC/index generation (C3–C4) provide the structural data needed to scope selective exports.  
- Existing fixtures include tutorial + reference bundles; none model multi-technology filtering scenarios.

## 🧭 Goals & Success Criteria
- Define the CLI contract for technology filtering, including naming conventions, allowlist semantics, and failure behavior when filters do not match bundle contents.  
- Identify required fixtures or synthetic DocC bundles that include multiple technologies to validate filter coverage.  
- Outline deterministic behavior: filtered runs must hash-identically on repeat executions and must not alter unfiltered conversion outputs.  
- Produce a TDD plan (failing tests/specs) covering CLI argument parsing, filtered pipeline execution, and log/summary counts.

## 🔗 Dependencies & Inputs
- **Prerequisites**: Completed argument parsing infrastructure (B2), bundle normalization/extraction (B3–B4), metadata parsing + internal model (B5–B6), link graph + TOC/index outputs (C3–C4).  
- **External blockers**: None identified; E3 remains unrelated to this scope.  
- **Reference materials**: workplan.md §Phase F enhancement backlog, prior CLI flag implementations (`--force`, `--format`), and release determinism gates (C5/D2).

## 🧪 Testing & Fixture Plan (Pre-Implementation)
1. Author failing CLI tests specifying the `--filter technology` flag syntax, error messaging for missing/unknown technologies, and combination with existing flags (`--output`, `--force`, `--format`).
2. Design integration tests that run the full pipeline against a multi-technology fixture, asserting:
   - Only targeted technologies are converted (Markdown, link graph, TOC/index) while counts/logs reflect filtered scope.
   - Determinism remains intact (hash comparisons across repeated filtered runs).
3. Introduce or extend fixtures to include at least two technologies with overlapping tutorial/reference content; document provenance and expected filtered outputs.
4. Extend release gate scripts as needed to exercise the filtered path in CI once implementation begins.

## 📌 Decision Points to Resolve
- Flag spelling and arity: single value vs. repeatable `--filter technology <name>` list; casing/normalization rules.  
- Behavior when filters exclude all content: error vs. empty output with warning.  
- Interaction with existing selection mechanisms (if any) and future extensibility (e.g., tag/category filters).  
- Performance considerations: avoid duplicate parsing/rendering work when multiple filters overlap.

## 🚀 Next Steps (Before START)
- Confirm acceptance criteria against workplan.md Phase F backlog and update TODO/workplan if additional follow-ups appear.  
- Draft the failing test list and fixture requirements in this note; refine into `START` scope once confirmed.  
- Identify impacts on documentation (README usage flags, help text) to be addressed during implementation.

## 📅 Status
- **State**: Complete (START)
- **Owner**: docc2context agent
- **Last Updated**: 2025-11-25

## ✅ Implementation Summary
Completed full TDD implementation of technology filtering feature:

1. **CLI Flag**: Added `--technology <name>` flag (repeatable for multiple modules)
2. **Pipeline Integration**: Extended `MarkdownGenerationPipeline.generateMarkdown()` with optional `technologyFilter` parameter
3. **Filtering Logic**: Symbol references filtered by `moduleName`; tutorials/articles unaffected
4. **Summary Enhancement**: Added `symbolCount` field to `Summary` struct
5. **Tests**: Added 8 new tests (3 CLI + 5 pipeline tests), all passing
6. **Documentation**: Updated README with usage guidance and help text

### Test Results
- All 96 tests passing (15 skipped platform-specific)
- New tests validate:
  - CLI flag parsing (single and multiple filters)
  - Symbol filtering correctness
  - Determinism of filtered outputs
  - Tutorials/articles independence from filtering

### Design Decisions
- **Flag name**: `--technology` (simpler than `--filter technology`)
- **Scope**: Symbol references only (tutorials/articles always included)
- **Empty filter behavior**: Returns 0 symbols (no error)
- **Determinism**: Maintained through sorted set operations
