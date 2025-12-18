# F10 — Swift-DocC Render-Archive Tutorial Parity (Decode + Markdown)

## Motivation
Real-world `.doccarchive` inputs often include interactive tutorials authored with the `@Tutorial` directive (Swift-DocC 5.5+). When converting `SpecificationKit.doccarchive`, `docc2context` emits warnings like:
- `invalidTutorialPage(.../data/tutorials/.../gettingstarted.json)`
- `invalidTutorialPage(.../data/tutorials/.../advancedpatterns.json)`

These warnings indicate the tutorial render-node JSON exists but does not match our current `DoccTutorial` decoding schema, so tutorial pages are skipped or partially rendered. This prevents parity with Xcode’s DocC browser and reduces usefulness of the generated Markdown for learning-oriented docs.

## Desired Outcome
- Decode real Swift-DocC tutorial render nodes without warnings (or with clear, recoverable warnings for truly unsupported elements).
- Render tutorial pages into deterministic Markdown that preserves the meaningful tutorial structure:
  - Intro text/media (as text + optional image references)
  - Sections and steps
  - Code blocks referenced by steps
  - Assessments (questions/choices) in a readable Markdown form
- Add test coverage that locks tutorial Markdown output and prevents regressions.

## Scope
- Primary repro: `DOCS/INPROGRESS/SpecificationKit.doccarchive`
  - `data/tutorials/specificationkit/gettingstarted.json`
  - `data/tutorials/specificationkit/advancedpatterns.json`
- Output mode: `--format markdown` and `--symbol-layout single` (tutorial output unaffected by symbol layout, but we validate in the same run).
- Maintain offline-friendly conversion and determinism.

## Non-goals
- Pixel-perfect parity with Xcode’s UI layout.
- Full support for every tutorial directive variant on day one; start with common structures and degrade gracefully.

## Proposed Approach
1. Inspect tutorial render-node JSON schema for the repro pages and map it to a tolerant internal model (new or expanded tutorial structs).
2. Implement a “Swift-DocC render archive tutorial page” decoder that:
   - prefers typed decoding
   - falls back to a lossy/manual decode for known schema drift cases
   - never crashes the pipeline (warn + skip unsupported subcomponents)
3. Extend the Markdown renderer to emit:
   - `## Intro`, `## Sections`, `### Step N` structure
   - code listings as fenced blocks (Swift)
   - assessments as nested bullet lists
4. Add fixtures/tests:
   - Either (a) add minimal tutorial render-node fixtures under `Fixtures/` or (b) add a small, provenance-noted real-world tutorial fixture if feasible.
   - Add snapshot tests for at least one tutorial page exhibiting steps + code + assessments.

## Validation Strategy
- `swift test`
- `python3 Scripts/lint_markdown.py`
- Determinism smoke: run conversion twice on the same fixture and hash outputs.

## Current State
## Selection (SELECT_NEXT)
- Selected next because it eliminates the most visible real-world warning (`invalidTutorialPage`) and unlocks tutorial Markdown parity for `@Tutorial` content, complementing F5/F5.1/F9’s symbol/article parity work.
- Phase: **C (Markdown generation)** — tutorial render-node decoding + Markdown emission.
- Priority: **P1** (important). Rationale: tutorials are a major DocC surface area; skipping them makes outputs feel incomplete even when symbol pages are good.

## Dependencies / Preconditions
- Existing render-archive detection and bundle walking are in place.
- Real-world repro archive available locally: `DOCS/INPROGRESS/SpecificationKit.doccarchive`.
- Existing tutorial pipeline already tolerates failures by warning and continuing; we’ll replace warnings with successful decode for supported shapes.

## Planned Execution (High Level)
1. Inspect the schema of `gettingstarted.json` and `advancedpatterns.json` under `data/tutorials/...` to enumerate block/inline types and structure.
2. Define/extend internal tutorial models to match render-node JSON (tolerant decoding, lossy fallback if needed).
3. Implement Markdown emission rules for intro/sections/steps/code/assessments with determinism constraints.
4. Add fixture-backed snapshot tests that lock tutorial pages and prevent regressions.

## Current State
- Selected; ready to start with START.md.
