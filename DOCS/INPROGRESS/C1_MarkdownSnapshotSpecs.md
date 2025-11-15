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

## First Failing Test to Author
- `MarkdownSnapshotSpecsTests.test_tutorialOverviewMatchesSnapshot`
  - File: `Tests/Docc2contextMarkdownTests/MarkdownSnapshotSpecsTests.swift` (new).
  - Behavior: load `Fixtures/TutorialCatalog.doccarchive`, build the internal model, render the tutorial volume overview Markdown, and compare it to `Tests/Docc2contextMarkdownTests/Fixtures/Snapshots/TutorialCatalog/volume_overview.md` using the snapshot harness from A2.
  - Rationale: establishes the first executable spec for tutorial outputs and seeds the directory structure future snapshots will follow.

## Validation Plan
- Primary guard: `swift test --filter MarkdownSnapshotSpecsTests` once the failing test exists.
- Full suite + determinism gates: `swift test` and `Scripts/release_gates.sh` before landing snapshots to ensure fixture hashing remains stable.
- Snapshot files will live under `Tests/Docc2contextMarkdownTests/Fixtures/Snapshots/` with README notes describing hash/diff expectations.

## Subtasks & Checklist
- [ ] Finalize snapshot directory layout + README under `Tests/Docc2contextMarkdownTests/Fixtures/Snapshots/`.
- [ ] Implement the failing tutorial overview snapshot test described above.
- [ ] Expand fixtures/tests for tutorial chapters and reference articles following the same harness.
- [ ] Document normalization/diff helpers (line endings, code block fences) once discovered.

## Blocking Questions
- Do tutorial chapters require separate Markdown files for each step, or a single aggregated page for snapshotting?
- How should inline assets (images, callouts) be represented in Markdown snapshots—do we strip them, replace with placeholders, or include deterministic references?

## Immediate Next Action
Begin editing `Tests/Docc2contextMarkdownTests/MarkdownSnapshotSpecsTests.swift` to add `test_tutorialOverviewMatchesSnapshot`, referencing the tutorial catalog fixture and pointing the assertion at `Fixtures/Snapshots/TutorialCatalog/volume_overview.md`. Commit the failing test before implementing any renderer code.
