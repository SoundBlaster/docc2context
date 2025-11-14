# A3 – Establish DocC Sample Fixtures

## Objective
Stand up the canonical `Fixtures/` directory with at least two DocC bundles (tutorial-focused + API/article-focused) plus provenance notes so downstream parser/CLI work has deterministic sample inputs.

## Relevant PRD References
- `DOCS/PRD/docc2context_prd.md` – Phase A, item A3 "Establish DocC Sample Fixtures" (deterministic bundles + manifest).
- `DOCS/workplan.md` – Phase A sequencing (A2 utilities precede fixture ingestion, A3 unblocks B-phase parsing specs).

## Dependencies
- [x] **A2 – XCTest utilities / snapshot harness**: harness landed and now loads bundles relative to `Fixtures/`.
- [x] Licensing confirmation resolved by authoring synthetic bundles under CC0 so archives may live in-repo.

## Test Plan
- `swift test --filter FixturesTests` (to be added) will verify the harness loads each bundle path listed in `Fixtures/manifest.json`.
- Determinism check: `find Fixtures -name '*.doccarchive' -print0 | xargs -0 shasum -a 256` must match the manifest checksums.
- Once CLI wiring exists, run `swift run docc2context --input Fixtures/<bundle> --output .build/fixture-smoke` to ensure fixtures cover tutorials/articles.

## Validation Inputs & Artifacts
- `Fixtures/README.md` documents storage/layout/provenance expectations. ✅
- `Fixtures/manifest.json` now includes canonical entries for each bundle plus schema metadata. ✅
- Target bundles: (1) tutorial-heavy sample (SwiftUI Tutorials, Scrumdinger, etc.), (2) API/article-heavy sample (SamplePackage, DocC article example).

## Subtasks Checklist
- [x] Draft fixture layout, provenance checklist, and manifest schema (`Fixtures/README.md`, `Fixtures/manifest.json`).
- [x] Inventory publicly redistributable DocC bundles, capture their licenses, and choose two primary fixtures (result: synthetic CC0 bundles committed locally).
- [x] Normalize selected bundles into `.doccarchive/` directories under `Fixtures/` plus checksum files.
- [x] Populate `Fixtures/manifest.json` with bundle metadata and determinism data.
- [x] Add README sections per bundle describing coverage and how to refresh it.
- [ ] Write smoke XCTest covering the manifest-driven loader from task A2.

## Blocking Questions / Risks
- Apple-supplied tutorial bundles may have redistribution limits—mitigated by shipping synthetic CC0 bundles instead.
- Repository size could bloat; may need trimming strategy or `git lfs` decision if future fixtures grow.

## Immediate Next Action
Integrate these bundles into an XCTest loader once parser work begins so future fixtures stay exercised.

## Completion Summary
- Authored two synthetic DocC bundles (`TutorialCatalog.doccarchive`, `ArticleReference.doccarchive`) containing tutorial, article, and symbol graph payloads sized for Git.
- Documented each bundle's provenance/usage guidance in `Fixtures/README.md` and populated deterministic metadata in `Fixtures/manifest.json` with SHA-256 hashes and byte sizes.
- Validated the bundles through the fixture manifest script plus full release gates to ensure determinism logging references the new entries.

## Validation Evidence
- `swift test`
- `Scripts/validate_fixtures_manifest.py Fixtures/manifest.json`
- `Scripts/release_gates.sh`

## Follow-Ups
- Add manifest-driven XCTest coverage once parser/detection code consumes fixtures (tracked as part of tasks B3/B5).
- Revisit bundle content if later phases require localized examples or heavier symbol graphs.

## Progress Log
- 2024-03-02 — Ran START ritual: documented fixture scope, licensing risks, and manifest schema inside this note to unblock execution.
- 2025-11-15 — Authored synthetic tutorial/article bundles, updated manifest + README, and validated via `swift test` + release gates; ready for ARCHIVE.
