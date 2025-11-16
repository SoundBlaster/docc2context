# C2 – Generate Markdown Files

## Summary & Scope
- **Goal:** Implement the Markdown generation/export stage so the CLI writes deterministic Markdown files for each DocC page
  (tutorial volumes, chapters, tutorials, and reference articles) using the renderer already proven by the C1 snapshot specs.
- **PRD Mapping:** Phase C §"Generate Markdown Files" — convert DocC content into Markdown that mirrors headings, prose, code,
  metadata, and navigation plus maintain deterministic file naming.
- **Success Criteria:**
  - Running `docc2context <fixture> --output <dir>` produces Markdown outputs whose contents match the locked snapshots for the
    targeted page types.
  - Output directory structure + file names derive from DocC identifiers (stable between runs and across platforms).
  - CLI logs continue to summarize generation counts without regressing previously archived logging behaviors.
  - Conversion gracefully handles both DocC directories and `.doccarchive` inputs, reusing detection/extraction flows from Phase B.

## Dependencies & Current State
- ✅ **Prereqs Satisfied:** B1–B6 input + model pipeline, archive extraction (B4), structured logging (D1), and all C1 snapshot
  specs.
- ⚠️ **Gap:** `Docc2contextCommand.run` currently stops after argument parsing and prints a placeholder summary; no pipeline
  orchestration or filesystem writes exist.
- ⚠️ **Gap:** No integration tests assert that Markdown files are written to disk or match snapshots per identifier.
- ⚠️ **Gap:** File/slug naming + directory layout undefined; need deterministic mapping from DocC identifiers to output paths.

## Proposed Approach
1. **Introduce a Generation Coordinator**
   - Add a type (e.g., `MarkdownGenerationPipeline`) that composes: input detection/extraction → metadata parsing → internal model
     build → Markdown rendering → filesystem writes.
   - Ensure the coordinator accepts dependencies (parser, builder, renderer, file manager) for testability.
2. **Define Output Layout & Naming**
   - Base folder: `<output>/markdown/` or root output directory.
   - Use identifier-driven slugs (lowercase, `/` preserved as directories, sanitized characters) with `.md` extension.
   - Mirror DocC hierarchy: tutorials under `tutorials/`, articles under `articles/`, etc., to ease navigation + future TOC tasks.
3. **Render and Persist Content**
   - Iterate over `DoccBundleModel.tutorialVolumes`, rendering overview + chapter pages and optional tutorial detail pages (future
     work?) to satisfy snapshot scope.
   - Render reference/articles based on `DoccBundleModel.referenceArticles` and any other article buckets.
   - Write Markdown files atomically and ensure newline endings match snapshot expectations (final `\n`).
4. **CLI Integration**
   - Replace placeholder summary in `Docc2contextCommand.run` with pipeline invocation using parsed options.
   - Honor `--force` (clean output directory if needed) and report counts/logs through existing logging infrastructure.
5. **Determinism Hooks**
   - Provide helper to hash file contents for future C5 determinism checks (optional to implement fully later but plan API now).

## Test & Validation Plan
- **Snapshot Reuse:** Reuse `MarkdownSnapshotSpecsTests` to assert renderer output equals existing snapshots; integrate them into
  new integration tests by reading written files and comparing to snapshots (or verifying pipeline output equals renderer string).
- **New Tests:**
  1. `MarkdownGenerationPipelineTests` — converts the tutorial fixture and asserts expected files exist with contents identical to
     snapshots.
  2. CLI-level test (e.g., `Docc2contextCommandTests`) that runs the command against a fixture in a temp directory and inspects
     output to ensure files exist and summary counts match.
  3. Failure-path tests for existing output directory without `--force`, write errors, and identifier sanitization edge cases.
- **Release Gates:** Update `Scripts/release_gates.sh` (if necessary) to include any new integration test bundles or determinism
  validations once pipeline lands.

## Risks & Open Questions
- **Output Scope:** Do we emit tutorial *detail* pages in C2 or defer to later C-phase tasks? For now, focus on the entities with
  snapshots (volume overview, first chapter, reference article) but design iteration loops so additional entities drop in easily.
- **Large Bundles:** Need to ensure renderer writes streaming-friendly (avoid building huge strings). Might require chunked writes
  once tutorial detail pages land.
- **Symbol References:** Link graph generation (C3) will need identifier mapping; ensure file naming scheme captures canonical IDs
  to avoid rework.

## Next Steps before START Command
1. Finalize identifier → path mapping spec (document in PR or README once implemented).
2. Outline new XCTest cases mentioned above (failing first) before touching production code.
3. Coordinate with TODO list (done) and ensure no other tasks conflict with C2 scope.
4. Prepare temporary directories + fixture loaders needed for CLI end-to-end tests.

## Implementation Notes – 2025-02-14
- Added a `MarkdownGenerationPipeline` coordinator that loads DocC metadata, renders tutorial volumes/chapters + reference articles, and writes deterministic files into `<output>/markdown/`.
- Integrated the pipeline into `Docc2contextCommand` so the CLI now creates Markdown outputs, enforces `--force` semantics, and prints generation counts.
- Introduced `MarkdownGenerationPipelineTests` plus CLI/command integration tests that assert files land on disk and match the existing Markdown snapshots.
- Recorded new snapshots for the pipeline harness to keep the renderer + file layout deterministic.
- Updated README + TODO status to reflect the completed C2 milestone; ready for ARCHIVE once reviewed.
