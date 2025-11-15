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

## Completion Summary (2025-11-16)
- Cataloged Markdown page types for tutorial volume overviews, per-chapter detail pages, standalone articles, and hybrid tutorial/article symbols while mapping each one back to the Phase C acceptance criteria.
- Locked the snapshot layout by defining `Tests/__Snapshots__/MarkdownSnapshotSpecsTests/{testName}.md` along with fixture-driven naming that mirrors DocC identifiers so failing specs can be recorded deterministically.
- Outlined the helper utilities (Markdown normalizer, deterministic diff harness, chapter/article loaders) that the renderer and snapshot suites will require, feeding them directly into the `C1_MarkdownSnapshotSpecs.md` note for execution.
- Captured outstanding metadata and media questions so follow-up TODO items can resolve them without losing context.

## Validation Evidence
- Reviewed `PRD/docc2context_prd.md` Phase C scope plus the workplan entries to ensure every Markdown entity expected in C1 is represented in this outline.
- Cross-checked the fixture coverage from `Fixtures/TutorialCatalog.doccarchive` and `Fixtures/ArticleReference.doccarchive` along with the existing `MarkdownSnapshotSpecsTests.test_tutorialOverviewMatchesSnapshot` spec to verify the snapshot layout is compatible with the shipping harness.
- Confirmed that no new code/tests were required for this planning task beyond referencing the archived B6 internal model + serialization helpers already validated by `swift test`.

## Follow-Ups
- Continue executing `C1 Markdown Snapshot Specs` so tutorial chapter and reference article Markdown outputs gain recorded snapshots (tracked in `DOCS/todo.md`).
- Revisit media asset handling during renderer implementation to decide whether placeholders or streamed references keep Markdown deterministic; promote a TODO entry once the preferred approach is selected.
