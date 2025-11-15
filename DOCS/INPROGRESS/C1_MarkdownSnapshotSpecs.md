# C1 Markdown Snapshot Specs

## Summary
- **Goal:** Author the first set of deterministic Markdown snapshot fixtures + failing tests for tutorials, tutorial chapters, and articles so the renderer implementation (C2) can begin red-green cycles.
- **Why now:** Phase A/B deliverables plus the `C1 Markdown Rendering Strategy Outline` work-in-progress establish internal model readiness but no executable specs exist yet. Advancing snapshot coverage keeps Phase C unblocked and satisfies the workplan dependency ordering.

## Dependencies & Inputs
- PRD §Phase C and workplan §Phase C call for snapshot-driven Markdown development before generator code.
- B6 internal model implementation + serialization snapshots (see `DOCS/TASK_ARCHIVE/11_B6_InternalModel/` and `DOCS/TASK_ARCHIVE/13_B6_SerializationCoverage/`) supply the structured data these tests will feed into renderers.
- Fixtures established in A3 (`Fixtures/TutorialCatalog.doccarchive`, `Fixtures/ArticleReference.doccarchive`) and any outline notes captured in `DOCS/INPROGRESS/C1_MarkdownRenderingStrategy.md`.
- Snapshot harness utilities from A2 plus README conventions for determinism and release gating.

## Success Criteria
1. Define a directory layout + naming convention for Markdown snapshots that mirrors DocC hierarchy (bundle/volume/chapter/page) and document it in this note + outline.
2. Add placeholder/failing XCTest cases (e.g., `MarkdownSnapshotSpecsTests`) referencing the planned snapshot files so CI records the pending work.
3. Capture fixture TODOs for any missing page types (e.g., tutorial intro, chapter article, technology article) and link them to follow-up tasks if out of scope here.
4. Update `DOCS/todo.md` / `DOCS/INPROGRESS/` when the spec is ready for implementation tasks (handoff to START command).

## Planned Steps
1. Re-read the outline + PRD to list all Markdown page types (tutorial overview, chapters, articles, callouts, symbol detail) that require fixtures.
2. Define deterministic file naming + storage path under `Tests/` (likely `Tests/Docc2contextMarkdownTests/Fixtures/`) and record expectations for hashed output directories.
3. Sketch failing XCTest cases referencing the snapshots (even if placeholders initially) and describe normalization rules (line endings, whitespace, metadata blocks) to enforce determinism.
4. Enumerate open questions + future START tasks (e.g., media references, link graph cross-checks) at the bottom of this note.

## Validation Plan
- Validation occurs once the START command implements the snapshot files/tests; for this selection task we will review the note + TODO updates during PR review, ensuring dependencies and acceptance criteria tie back to the PRD.

## Open Questions / Risks
- Need to confirm whether tutorial chapters use multiple Markdown files (intro vs. steps) or a single combined page per DocC semantics.
- Handling of inline assets (images, code listings) may require additional normalization helpers beyond existing harness utilities.
- Articles vs. tutorials may require different metadata/front-matter structures; must be clarified before snapshot authoring begins.
