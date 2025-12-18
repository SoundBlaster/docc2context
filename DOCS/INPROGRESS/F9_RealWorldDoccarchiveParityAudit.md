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
- Task created; investigation not started yet.
