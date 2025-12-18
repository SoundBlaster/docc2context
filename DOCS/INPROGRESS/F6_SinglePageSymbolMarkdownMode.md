# F6 Single-Page Symbol Markdown Mode

**Status:** Selected (planning)  
**Owner:** docc2context agent  
**Selected on:** 2025-12-18  
**PRD reference:** `DOCS/PRD/docc2context_prd.md` §5 (F6)  
**Workplan reference:** `DOCS/workplan.md` (Phase F, F6)  
**Depends on:** F5 (symbol render-node decoding + symbol page rendering)

## Objective
Add an opt-in mode that renders each DocC symbol (struct/class/enum/protocol/etc.) as a **single Markdown document**, instead of the current “tree layout” that creates a folder per symbol with nested child pages.

This is intended to make symbol documentation easier to ingest as standalone documents (LLM context chunks), while preserving the current behavior as the default.

## Problem statement
Swift-DocC render archives naturally model symbol documentation as a hierarchy:
`/documentation/<module>/<symbol>/<member>/...`

Mirroring that hierarchy to the filesystem creates many directories and `index.md` files. For symbols like `BenchmarkComparator`, this looks messy and makes it harder to treat “the symbol doc” as one cohesive Markdown artifact.

## Proposed CLI UX
Add a new flag that controls how symbol pages are emitted:
- `--symbol-layout tree` (default; current behavior)
- `--symbol-layout single` (new; one Markdown file per symbol)

Alternative naming (if “layout” conflicts with existing flags):
- `--symbol-pages single|tree`
- `--symbol-output single|tree`

## Scope (what START should deliver)
1. **Single-page symbol emission**
   - In single mode, emit a single Markdown file for a symbol page (e.g. `BenchmarkComparator`) that includes:
     - Summary
     - Declarations
     - Topics (grouped)
     - Relationships (grouped)
   - Inline member items by title (resolved via `references`), optionally with short signatures/identifiers.
2. **File path strategy (avoid collisions)**
   - Choose a deterministic file path that does not collide with the existing tree layout.
   - Recommended: still use the DocC URL path, but end the symbol with `.md` instead of a directory, e.g.:
     - Tree: `markdown/documentation/docc2contextcore/benchmarkcomparator/index.md`
     - Single: `markdown/documentation/docc2contextcore/benchmarkcomparator.md`
3. **Snapshot + determinism tests**
   - Add snapshot tests for `BenchmarkComparator` in single mode.
   - Ensure determinism remains byte-identical across runs.
4. **No regression**
   - Default behavior remains unchanged (tree layout).
   - Existing tutorial/article outputs and F5 symbol-tree outputs remain stable.

## Non-goals
- Perfect “full text” parity with Xcode for every child member page (initially).
- Rendering every nested symbol/member body inline (we can incrementally add that later).

## Risks / constraints
- Some symbol pages have both a parent page and many child pages; single-page mode must avoid name/path collisions.
- Title/identifier resolution must remain deterministic and stable across toolchains.
- For nested symbols, decide whether to generate separate single pages per nested symbol or embed them only as entries.

## Validation plan (START)
- `swift test` (including new snapshots)
- `python3 Scripts/validate_fixtures_manifest.py Fixtures/manifest.json`
- `python3 Scripts/lint_markdown.py`

## Acceptance criteria
- Running conversion in single mode produces a single Markdown file for `BenchmarkComparator` (and at least one other representative symbol) that is readable and includes Topics/Relationships/Declarations.
- Snapshot tests lock the single-page output.
- Default output remains the existing tree layout.

