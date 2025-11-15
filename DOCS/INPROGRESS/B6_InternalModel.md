# B6 – Build Internal Model

## Scope & Intent
- Translate parsed DocC metadata (Info.plist, render nodes, tutorials/articles, symbol graphs) into ergonomic Swift structs that downstream Markdown generation can consume without re-reading bundle files.
- Mirror the acceptance criteria in [PRD §Phase B](../PRD/docc2context_prd.md) and [phase_b.md](../PRD/phase_b.md) by validating serialization/deserialization of the internal model via XCTest.
- Capture mapping notes between the internal model and planned Phase C generators so snapshot specs (C1) can reference consistent identifiers, titles, and hierarchy metadata.

## Dependencies
- ✅ **B5** DocC metadata parser provides typed inputs for each document, tutorial, and symbol graph entry.
- Fixtures created in A3 plus release gates from A4 ensure deterministic sample data for round-trip tests.

## Acceptance Criteria
1. Swift types exist for tutorials, articles, volumes/chapters, symbol references, and shared metadata (identifiers, technology, locale, hierarchy, assets).
2. Unit tests cover constructing models from parsed metadata plus encoding/decoding (JSON or plist) to guarantee stability for future serialization.
3. Documentation within the source or tests describes how each model maps onto expected Markdown outputs (headings, callouts, code listings) to unblock C1 snapshot specs.
4. Model layer exposes deterministic ordering guarantees so downstream generators can iterate pages predictably.

## Execution Plan
- [ ] Audit current parsed metadata structs (`Sources/Docc2contextKit/Parsing`) to enumerate required fields for tutorials/articles/symbols.
- [ ] Sketch Swift model definitions plus protocols (e.g., `DocCPage`, `DocCLinkable`) in a draft test to drive implementation (red tests first).
- [ ] Author serialization tests exercising a representative tutorial, article, and symbol graph entry derived from fixtures, ensuring round-trip fidelity and deterministic ordering.
- [ ] Update README or inline docs (if needed) summarizing how the model feeds future Markdown generation steps and log any open questions for C1.

## Open Questions / Notes
- Determine whether link graph edges should live in core models or be computed lazily in C3; start by representing outgoing references on each page to simplify later adjacency calculations.
- Confirm whether localized content should be flattened now or preserved per-locale; default to base locale for initial model with TODO hooks for locale expansion.
