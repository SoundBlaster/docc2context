# A3 – Establish DocC Sample Fixtures

## Objective
Stand up the canonical `Fixtures/` directory with at least two DocC bundles (tutorial-focused + API/article-focused) plus provenance notes so downstream parser/CLI work has deterministic sample inputs.

## Relevant PRD References
- `DOCS/PRD/docc2context_prd.md` – Phase A, item A3 "Establish DocC Sample Fixtures" (deterministic bundles + manifest).
- `DOCS/workplan.md` – Phase A sequencing (A2 utilities precede fixture ingestion, A3 unblocks B-phase parsing specs).

## Dependencies
- [ ] **A2 – XCTest utilities / snapshot harness**: still in progress; fixture loader APIs must align with the utilities defined there.
- [ ] Licensing confirmation for chosen bundles (SwiftUI Tutorials snapshot, SamplePackage, or equivalent) – required before adding archives to Git.

## Test Plan
- `swift test --filter FixturesTests` (to be added) will verify the harness loads each bundle path listed in `Fixtures/manifest.json`.
- Determinism check: `find Fixtures -name '*.doccarchive' -print0 | xargs -0 shasum -a 256` must match the manifest checksums.
- Once CLI wiring exists, run `swift run docc2context --input Fixtures/<bundle> --output .build/fixture-smoke` to ensure fixtures cover tutorials/articles.

## Validation Inputs & Artifacts
- `Fixtures/README.md` documents storage/layout/provenance expectations. ✅
- `Fixtures/manifest.json` currently contains a schema stub; future commits will replace placeholder entries with real bundles. ✅
- Target bundles: (1) tutorial-heavy sample (SwiftUI Tutorials, Scrumdinger, etc.), (2) API/article-heavy sample (SamplePackage, DocC article example).

## Subtasks Checklist
- [x] Draft fixture layout, provenance checklist, and manifest schema (`Fixtures/README.md`, `Fixtures/manifest.json`).
- [ ] Inventory publicly redistributable DocC bundles, capture their licenses, and choose two primary fixtures.
- [ ] Normalize selected bundles into `.doccarchive/` directories under `Fixtures/` plus checksum files.
- [ ] Populate `Fixtures/manifest.json` with bundle metadata and determinism data.
- [ ] Add README sections per bundle describing coverage and how to refresh it.
- [ ] Write smoke XCTest covering the manifest-driven loader from task A2.

## Blocking Questions / Risks
- Apple-supplied tutorial bundles may have redistribution limits—need clarity before checking in archives.
- Repository size could bloat; may need trimming strategy or `git lfs` decision.

## Immediate Next Action
Research licensing/permitted redistribution for candidate DocC bundles (SwiftUI Tutorials, SamplePackage) and capture findings in this note before attempting downloads/imports.
