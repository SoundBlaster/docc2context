# C1 Markdown Snapshot Specs

## Objective
Translate the Phase C requirement for deterministic Markdown exports into executable specs by authoring snapshot fixtures and failing tests that describe tutorial volumes, chapters, and articles before any renderer code lands.

## Relevant PRD Paragraphs
- `PRD/docc2context_prd.md` §Phase C (C1 Snapshot Specs) – mandates snapshot-first development and deterministic Markdown artifacts.
- `PRD/phases.md` → Phase C checklist – calls out snapshot coverage for tutorials and articles as the next gating milestone.

## Dependencies
- ✅ `DOCS/TASK_ARCHIVE/11_B6_InternalModel/` and `13_B6_SerializationCoverage/` supply the canonical internal model + serialization helpers these specs will drive.
- ✅ Fixtures from A3 (`Fixtures/TutorialCatalog.doccarchive`, `Fixtures/ArticleReference.doccarchive`).
- ➡️ Outline context stored in `DOCS/INPROGRESS/C1_MarkdownRenderingStrategy.md` to align terminology and page coverage.

## First Snapshot Spec Authored
- `MarkdownSnapshotSpecsTests.test_tutorialOverviewMatchesSnapshot`
  - File: `Tests/Docc2contextCoreTests/MarkdownSnapshotSpecsTests.swift`.
  - Behavior: loads `Fixtures/TutorialCatalog.doccarchive`, builds the internal model, renders the tutorial volume overview Markdown through `DoccMarkdownRenderer.renderTutorialVolumeOverview`, and compares it to `Tests/__Snapshots__/MarkdownSnapshotSpecsTests/test_tutorialOverviewMatchesSnapshot().md` using the harness from A2.
  - Rationale: establishes the executable spec for tutorial overview outputs and seeds the directory structure future snapshots will follow.

## Validation Plan
- Primary guard: `swift test --filter MarkdownSnapshotSpecsTests` (already run to record and verify the tutorial overview snapshot).
- Full suite + determinism gates: `swift test` and `Scripts/release_gates.sh` before landing broader snapshot coverage to ensure fixture hashing remains stable.
- Snapshot files now live under `Tests/__Snapshots__/MarkdownSnapshotSpecsTests/`, matching the harness path shared with other suites.

## Subtasks & Checklist
- [x] Finalize snapshot directory layout by adding `Tests/__Snapshots__/MarkdownSnapshotSpecsTests/` alongside the shared harness docs.
- [x] Implement the tutorial overview snapshot spec + renderer entry point described above.
- [x] Expand fixtures/tests for tutorial chapters following the same harness (`test_tutorialChapterPageMatchesSnapshot`).
- [ ] Record reference article snapshot specs using `Fixtures/ArticleReference.doccarchive`.
- [ ] Document normalization/diff helpers (line endings, code block fences) once discovered.

### Active Focus: Reference Article Snapshot
- Next up: capture reference/article Markdown contracts using `ArticleReference.doccarchive` once tutorial coverage stabilizes.
- Ensure article snapshots document metadata, relationships, and any inline symbol references to unblock Phase C renderer work.

## Blocking Questions
- Do tutorial chapters require separate Markdown files for each step, or a single aggregated page for snapshotting?
- How should inline assets (images, callouts) be represented in Markdown snapshots—do we strip them, replace with placeholders, or include deterministic references?

## Immediate Next Action
Use the planning output from `C1_TutorialChapterSnapshot.md` to draft `MarkdownSnapshotSpecsTests.test_tutorialChapterPageMatchesSnapshot` targeting the `tutorialcatalog/tutorials/getting-started` Chapter 1 page, ensuring snapshot contents align with the documented heading/order/asset decisions before any renderer implementation begins.
