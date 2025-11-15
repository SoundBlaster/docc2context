# C1 Reference Article Snapshot Spec

## Objective
Capture the executable specification for Markdown output of reference/article pages so renderer work in Phase C can proceed test-first.
This task scopes the first article snapshot using `Fixtures/ArticleReference.doccarchive` and extends the C1 umbrella plan after the tutorial chapter coverage landed.

## Alignment & References
- `PRD/docc2context_prd.md` §Phase C → Markdown generation must be snapshot-driven with deterministic fixtures.
- `DOCS/workplan.md` → Only C1 tasks remain before renderer implementation (C2) can begin.
- `DOCS/INPROGRESS/C1_MarkdownSnapshotSpecs.md` → Umbrella note enumerating outstanding tutorial + article specs.
- `DOCS/TASK_ARCHIVE/15_C1_TutorialChapterSnapshot/` → Example plan/execution for prior tutorial chapter spec.

## Dependencies
- ✅ Phase B work (`DOCS/TASK_ARCHIVE/11_B6_InternalModel/`, `13_B6_SerializationCoverage/`) for canonical bundle models + deterministic serialization helpers.
- ✅ Snapshot harness from A2 plus tutorial overview/chapter specs proving out `MarkdownSnapshotSpecsTests` and fixture layout.
- ⚠️ Need fixture inspection of `ArticleReference.doccarchive` to catalog article metadata blocks (abstract, topics, on-page symbol references).

## Scope of This Planning Task
1. Define the first reference/article target inside the ArticleReference fixture (likely `documentation/ArticleReference/volume/reference-article`).
2. Describe the Markdown structure required in the snapshot covering:
   - Front matter / metadata (title, abstract, estimated time or technology tags if available).
   - Body content: prose sections, code listings, callouts.
   - Inline symbol/reference tables and relationships to tutorials or other articles.
   - Navigation footer linking to previous/next content and related resources.
3. Outline the failing test additions plus snapshot file naming conventions needed before START work begins.
4. Enumerate helper utilities or renderer entry points the test will exercise so START can implement them directly.

Out of scope: renderer implementation, fixture modifications, CLI changes, or link-graph generation beyond what the snapshot needs to assert.

## Proposed Test Additions
- `MarkdownSnapshotSpecsTests.test_referenceArticlePageMatchesSnapshot`
  - Loads the article fixture, builds the internal model for the targeted article node, and calls a new renderer API such as `DoccMarkdownRenderer.renderReferenceArticle`.
  - Persists the snapshot to `Tests/__Snapshots__/MarkdownSnapshotSpecsTests/test_referenceArticlePageMatchesSnapshot().md` following existing layout.
  - Expectations captured in the snapshot:
    - H1/H2 hierarchy mirrors DocC sectioning (`Topics`, `Overview`, `Discussion`).
    - Code listings represented with fenced blocks whose language derives from DocC metadata.
    - Inline symbol references normalized to deterministic Markdown links `[Symbol](./relative/path.md)`.
    - Asset references (images, downloads) either link to deterministic resource paths or placeholder text—decision recorded below.
    - Navigation footer summarizing “See also” or “Related tutorials/articles” entries to set the stage for later link-graph tasks.
- If the renderer lacks article support, the test may initially `XCTExpectFailure` but still records the intended structure so START can flip it once implementation lands.

## Data Collection Plan
1. Inspect `ArticleReference.doccarchive` contents (render JSON + metadata) to enumerate article IDs, section ordering, and asset references.
2. Map DocC fields to Markdown counterparts:
   - Article metadata → YAML-style header or first-level bullet table? (decision pending; likely prefer Markdown headings for determinism.)
   - Topics/relationships → ordered lists grouped by section.
   - Symbol references → tables with name, kind, destination anchors.
3. Draft snapshot outline offline (list headings + sample text) before updating tests to ensure diff noise stays low once recorded.

## Helper/Tooling Needs
- Markdown normalizer capable of trimming trailing whitespace and normalizing code block indentation; follow-ups may require updates in shared harness utilities.
- Renderer stub for reference articles that at least emits placeholder sections so snapshots can record deterministic scaffolding while implementation matures.
- Potential fixture loader helper to resolve `ArticleReference` nodes by identifier (similar to tutorial chapter loader added in archived task 15).

## Open Questions
1. **Metadata presentation** – Should article metadata (technology, platform availability) appear as a front-matter table or bullet list beneath the H1 title?
2. **Media handling** – Article fixture may include inline images; do we capture Markdown image tags referencing `Resources/` paths or store descriptive text placeholders?
3. **Symbol cross-links** – Are symbol references best represented as inline Markdown links or summarized in a dedicated “References” section at the bottom?

If unanswered by fixture review, promote follow-up TODO entries before START to keep renderer work unblocked.

## Success Criteria Before START
- TODO entry updated to reflect this focused article snapshot task is in progress.
- Snapshot test structure + file path decisions documented here (see Proposed Test Additions).
- Unknowns enumerated with next actions so implementation has a clear runway.

## Next Steps (for START command)
1. Author `MarkdownSnapshotSpecsTests.test_referenceArticlePageMatchesSnapshot` exercising the selected article ID.
2. Extend renderer + model loaders to feed the test (likely stubbed output first, then full implementation).
3. Record the snapshot file via the harness, ensuring deterministic normalization for headings, code listings, and reference tables.
4. Run `swift test --filter MarkdownSnapshotSpecsTests.test_referenceArticlePageMatchesSnapshot` and the full `swift test` suite before recording snapshots.
