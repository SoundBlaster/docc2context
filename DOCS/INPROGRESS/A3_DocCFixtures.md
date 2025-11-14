# A3 – Establish DocC Sample Fixtures

## Purpose & Scope
- **PRD Reference:** Phase A "Establish DocC Sample Fixtures" (DOCS/PRD/docc2context_prd.md §Phase A, ID A3).
- **Goal:** Collect at least two representative DocC bundles (e.g., SwiftUI Tutorials, SampleKit) and store them under `Fixtures/` with provenance documentation so tests can exercise tutorials, articles, and symbol-rich content.
- **Dependencies:** Requires TDD harness from A2 so fixture loaders + snapshot helpers already exist; unlocks B-phase parser/extractor work plus Markdown snapshot specs in Phase C.

## Current Context
- TODO entry A3 promoted from "Under Consideration" to "In Progress" per SELECT_NEXT run.
- No fixtures currently in repo; tests referencing DocC bundles would fail without these assets.

## Deliverables & Acceptance Criteria
1. `Fixtures/` directory populated with at least two DocC bundles (one tutorial heavy, one API/article heavy) plus README describing source and licensing.
2. Metadata manifest (e.g., `Fixtures/README.md` or JSON) enumerating bundle names, sizes, content coverage, and checksums for determinism.
3. Verification steps showing XCTest harness (A2) can load fixtures without disk errors (sample helper test or documented command output).
4. Guidance for future tasks on how to request additional fixtures or regenerate archives.

## Risks / Open Questions
- Need to confirm redistribution rights for any Apple-provided DocC bundles; may need to create synthesized sample if redistribution restricted.
- Repository bloat: must ensure fixtures are reasonably sized and possibly compressed while still deterministic.
- Might require scripting to convert `.doccarchive` into directory form; clarify desired canonical storage format.

## Next Steps
1. Inventory publicly available DocC bundles (SwiftUI Tutorials, SampleKit) and verify licenses for inclusion.
2. Define storage format and directory structure inside `Fixtures/` plus checksum workflow (e.g., `shasum -a 256`).
3. Draft provenance notes + manifest template in `Fixtures/README.md` and commit placeholder if fixture download is deferred.
4. Coordinate with A2 harness work to ensure fixture loader APIs expect this layout; add TODOs/tests referencing the fixtures once available.
