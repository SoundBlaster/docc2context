# F9 — Real-World `.doccarchive` Parity Audit (Missing Parts)

## Motivation
Real-world DocC render archives (example: `DOCS/INPROGRESS/SpecificationKit.doccarchive`) still show gaps vs Xcode’s DocC browser. Even after rendering headings, lists, and code listings, some pages may still be missing pieces that appear in Xcode (examples: parameter sections, availability, “See Also”, relationships metadata, or other block types).

This task is a focused investigation spike to identify what’s missing, classify it by render-node schema, and define a test-backed implementation plan.

## Desired Outcome
- A concrete, reproducible list of “missing in Markdown but present in Xcode” cases for a real `.doccarchive`.
- For each missing piece: the exact render-node JSON source location + the block/inline types involved.
- A prioritized implementation plan (with proposed tests) to close the gaps while preserving determinism.

## Scope
- Inputs: a committed/offline fixture when possible; otherwise `DOCS/INPROGRESS/SpecificationKit.doccarchive` as the real-world repro case.
- Outputs: Markdown in `--symbol-layout single` mode as the primary comparison surface.
- Non-goals: full pixel-perfect Xcode parity; focus on major content loss and structural correctness.

## Hypotheses / Likely Missing Areas
- Inline nodes not rendered: `link`, `reference`, `image`, `inlineCode`, `newTerm`, etc.
- Block nodes not rendered: `table`, `step`, `termList`, `callout`, `video`, `grid`, etc.
- Symbol metadata parity: availability/constraints, “Default Implementations” expansion, “See Also”, deprecation notes.
- Parameter/returns/throws formatting differences and topic grouping mismatches.

## Work Plan (Investigation First)
1. Pick 3–5 representative symbol pages from `SpecificationKit.doccarchive` that look incomplete vs Xcode.
2. For each page:
   - Identify missing sections in Markdown output.
   - Locate the corresponding content in `data/documentation/.../*.json`.
   - Record the JSON shapes/types that are currently ignored or lossy-decoded.
3. Propose an implementation strategy per missing type:
   - strict decode path (preferred) vs lossy fallback handling
   - deterministic Markdown mapping rules
4. Add fixtures/tests:
   - snapshot tests for symbol pages demonstrating the missing elements
   - minimal fixture updates (or add a dedicated real-world fixture if needed and justified)

## Validation Strategy
- Add/extend snapshot coverage for at least one real-world-like symbol page exhibiting each missing element.
- `swift test`
- `python3 Scripts/lint_markdown.py`
- Optional: determinism check by running conversion twice and hashing output.

## Current State
## Selection (SELECT_NEXT)
- Selected as the next investigation task because it directly targets remaining real-world parity gaps vs Xcode for render archives, building on F5/F5.1 without introducing new external dependencies.
- Phase: **C (Markdown generation)** — parity improvements to the Swift-DocC render archive decoding/rendering layer.
- Priority: **P1** (important). Rationale: improves trustworthiness of generated Markdown; reduces “empty/buggy output” reports on real projects.

## Dependencies / Preconditions
- Existing support for Swift-DocC render archives (F5) and initial discussion rendering (F5.1).
- Real-world repro archive: `DOCS/INPROGRESS/SpecificationKit.doccarchive` (already present locally).
- Determinism guardrails: snapshot tests and existing release gates.

## Planned Investigation Steps (Docs Only)
1. Generate output via: `swift run docc2context DOCS/INPROGRESS/SpecificationKit.doccarchive --output /tmp/f9-out --force --symbol-layout single`.
2. Identify 3–5 pages with clear Xcode-vs-Markdown mismatch; record file paths + screenshots/quotes in this note.
3. For each page, find corresponding render-node JSON under `DOCS/INPROGRESS/SpecificationKit.doccarchive/data/**` and capture:
   - `primaryContentSections` shapes (`kind`, block `type` values)
   - inline content node types (e.g., `reference`, `emphasis`, `link`)
4. Produce a prioritized “missing render types” checklist and propose how to map them to deterministic Markdown.
5. Define a TDD plan: fixtures/snapshots to lock each new mapping.

## Current State
- Selected; ready to start (implementation will follow START.md).
