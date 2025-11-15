# C1 Markdown Rendering Strategy Outline

## Summary
- **Goal:** document the Markdown rendering strategy for tutorials, articles, and supporting metadata so that C1 snapshot specs can be authored deterministically.
- **Why now:** Phase B implementation and serialization work are almost complete, and the workplan escalates Phase C next. The PRD requires snapshot-first development for Markdown generation, so we need a written outline before writing tests.

## Dependencies & Inputs
- B6 internal model + serialization coverage (archived under `DOCS/TASK_ARCHIVE/11_B6_InternalModel/` and `DOCS/TASK_ARCHIVE/13_B6_SerializationCoverage/`) provide canonical data sources for Markdown specs.
- Fixtures: `Fixtures/TutorialCatalog.doccarchive` (tutorial) and existing article/API bundles from A3.
- PRD §Phase C + workplan expectations describing snapshot-driven Markdown generation.
- TODO entry promoted to In Progress to track planning effort.

## Success Criteria
1. Define Markdown page types to cover in C1 (tutorial overview, chapter/article pages, symbol/article hybrids) referencing DocC structures.
2. Specify snapshot fixture locations + naming scheme for Markdown outputs, including deterministic hashing requirements.
3. Identify helper utilities/tests needed (e.g., Markdown normalizer, diff tooling) and document them in this note for follow-up START task.
4. Capture open questions (e.g., handling callouts, media references) with owners or next steps so later tasks can resolve them.

## Planned Steps
1. Review PRD Phase C requirements and existing DocC fixture content to catalog necessary page types.
2. Outline snapshot organization (directory tree, naming) plus any helper Swift utilities for Markdown normalization.
3. Document test strategy for each entity (tutorial volumes, chapters, articles) including determinism checks.
4. Update README or developer docs only if outline introduces new conventions; otherwise keep notes here until implementation tasks begin.

## Validation Plan
- Peer review within repo via future PR referencing this note.
- Ensure TODO/Workplan alignment: once outline is ready, promote follow-up START task for writing actual snapshot tests (C1).

## Open Questions / Risks
- Need clarity on whether tutorials/articles require different Markdown front matter or metadata blocks.
- Media asset handling may require streaming or placeholder references; need to confirm with fixtures.
- Deterministic ordering for navigation sections may require additional internal model sorting.
