# F5 Xcode-Parity Symbol Page Rendering (Swift-DocC Render Archives)

**Status:** Selected (planning)  
**Owner:** docc2context agent  
**Selected on:** 2025-12-18  
**PRD reference:** `DOCS/PRD/docc2context_prd.md` §5 (F5)  
**Workplan reference:** `DOCS/workplan.md` (Phase F, F5)  
**Depends on:** F4 (✅ implemented; pending archive)

## Objective
Align the Markdown export with Xcode’s DocC presentation by rendering Swift-DocC **render archive** symbol pages (`kind: "symbol"`) into Xcode-like Markdown.

Today, the converter primarily emits Markdown for `kind: "article"` nodes and synthetic fixture schemas; Xcode’s “Structure / Topics / Relationships / Declarations” views are driven by symbol render nodes and referenced collection groups.

## Problem statement
When converting a Swift-DocC render archive (e.g. `Fixtures/Docc2contextCore.doccarchive`), many pages that Xcode renders as rich symbol documentation (like `MarkdownGenerationPipeline`) currently appear as sparse “article” exports (or are missing entirely), because:
- `kind: "symbol"` nodes are not rendered as dedicated Markdown pages.
- `collectionGroup` nodes (e.g. “Equatable Implementations”) need to be presented as structured sub-sections, not as prose articles.
- `references` should be used to turn `doc://…` identifiers into readable titles in Topics/Relationships.

## Scope (what START should deliver)
1. **Symbol page Markdown rendering**
   - Emit a stable Markdown page for at least one representative symbol node from the `Docc2contextCore.doccarchive` fixture (target: `MarkdownGenerationPipeline`).
   - Render the same high-level structure users see in Xcode:
     - Summary/abstract
     - Topics (group headings + items)
     - Relationships (e.g. Conforms To / Inherits From when present)
     - Declarations (when present in `primaryContentSections`)
2. **Collection group integration**
   - Treat `metadata.role == "collectionGroup"` nodes as structured sub-sections reachable from the symbol page Topics, and render them in a readable way (titles + topic sections + referenced symbols).
3. **Reference resolution**
   - Use `references` to show human-readable titles (not just raw identifiers) for items in Topics/Relationships.
4. **Snapshot + determinism tests**
   - Add snapshot tests that lock the emitted symbol page Markdown (and any associated collection-group Markdown) and ensure determinism for repeated runs.

## Non-goals
- Full parity with every DocC presentation feature (e.g. availability matrices, language variants, external link resolution).
- Replacing the existing tutorial/article synthetic fixture pipeline (this task should layer render-archive support without regressions).

## Validation plan (START)
- `swift test` (including new snapshot coverage)
- `python3 Scripts/validate_fixtures_manifest.py Fixtures/manifest.json`
- `python3 Scripts/lint_markdown.py`

## Risks / constraints
- Swift-DocC render node schemas are rich; implement incrementally and lock behavior via focused snapshots.
- Keep outputs deterministic: ordering, whitespace, and identifier-to-title mapping must be stable.

## Acceptance criteria
- Converting `Fixtures/Docc2contextCore.doccarchive` produces a readable `MarkdownGenerationPipeline` symbol page Markdown that includes:
  - The one-line summary (“Converts a DocC bundle into deterministic Markdown and a link graph.”)
  - “Topics” with at least the `Summary` child and `generateMarkdown(...)` method listed by title (not only identifiers)
  - Any discovered `collectionGroup` sections listed in Topics (e.g. “Equatable Implementations”) with entries resolved by title
- Determinism tests prove two runs are byte-identical.

