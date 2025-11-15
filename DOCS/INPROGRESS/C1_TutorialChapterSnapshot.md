# C1 Tutorial Chapter Snapshot Spec

## Objective
Define the executable spec for tutorial chapter Markdown output so the renderer implementation can follow deterministic, snapshot-driven requirements. This planning note focuses on the first tutorial chapter page emitted from `Fixtures/TutorialCatalog.doccarchive`.

## Context & Dependencies
- **Phase Alignment:** Phase C requires Markdown generation to be locked down through snapshot specs before renderer code evolves.
- **Upstream Work:** Phase B internal model (`DoccInternalModelBuilder`) and serialization helpers are complete and already power the tutorial overview snapshot.
- **Existing Harness:** `MarkdownSnapshotSpecsTests` plus the shared snapshot directory (`Tests/__Snapshots__/MarkdownSnapshotSpecsTests/`) provide the mechanism for recording/validating Markdown output.
- **Fixture Coverage:** Tutorial data for `tutorialcatalog/tutorials/getting-started` includes chapters and steps needed for a realistic chapter page.

## Scope
- Author a failing snapshot test that exercises rendering of the first tutorial chapter page ("Getting Started" → Chapter 1) and records the expected Markdown contract.
- Capture deterministic ordering for chapter steps, callouts, and navigation anchors.
- Document assumptions about inline assets (images, code listings) so the renderer can decide between placeholders or normalized references.

## Out of Scope
- Implementing the renderer changes that satisfy the new snapshot (handled by a future START task).
- Covering tutorial article/reference pages (will be separate planning tasks).
- Modifying fixtures or CLI surface area.

## References
- `PRD/docc2context_prd.md` §Phase C → Snapshot-driven Markdown exports.
- `DOCS/INPROGRESS/C1_MarkdownSnapshotSpecs.md` → umbrella plan for C1, which this note extends.
- `Tests/Docc2contextCoreTests/MarkdownSnapshotSpecsTests.swift` → location for new spec.

## Proposed Test Additions
1. `test_tutorialChapterPageMatchesSnapshot`
   - Loads the tutorial catalog fixture, resolves the first chapter via the internal model, renders Markdown using a new `DoccMarkdownRenderer.renderTutorialChapterPage` entry point (or equivalent), and compares against a snapshot file `test_tutorialChapterPageMatchesSnapshot().md`.
   - Snapshot should exercise:
     - Chapter title/description headers.
     - Step subsections with numbered headings.
     - Inline assets (images, code listings) as normalized references (e.g., `![Image](Resources/...)` or placeholder text) consistent with the overview snapshot style.
     - Navigational footer linking to next chapter/article to anchor link-graph requirements later.

## Open Questions
- Should individual steps include full body Markdown or just summaries with references to step detail files?
- How are asset paths normalized when chapters reference shared media? Need deterministic scheme before recording the snapshot.
- Do code listings require fenced code blocks with language annotations derived from DocC metadata?

## Plan of Action
1. **Confirm Acceptance Criteria** by re-reading PRD Phase C to enumerate all fields (title, abstract, steps, estimated time, callouts) expected on chapter pages.
2. **Map Fixture Data** by inspecting the tutorial catalog fixture to identify the canonical chapter and enumerate its steps + assets.
3. **Draft Snapshot Layout** on paper/notepad describing heading hierarchy, bullet formatting, callout placeholders, and navigation sections.
4. **Update `MarkdownSnapshotSpecsTests`** with a new test case referencing the targeted chapter page and temporarily marked `XCTExpectFailure` until renderer work begins.
5. **Record Snapshot File** using the harness once the renderer stub emits deterministic placeholder content (may require temporarily stubbing output). Note: actual renderer implementation occurs in START command; during planning, outline expected file path/structure only.
6. **Document Asset Handling** decisions (placeholders vs. resource paths) back into the umbrella C1 note for alignment.

## Exit Criteria for Planning Phase
- Todo entry updated to call out the tutorial chapter snapshot focus.
- This note reviewed/linked from `DOCS/INPROGRESS/C1_MarkdownSnapshotSpecs.md`.
- Clear answers to open questions or a follow-up task identified if unknowns remain when coding starts.
