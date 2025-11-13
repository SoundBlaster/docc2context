# docc2context Agent Guide

These principles summarize the workflow encoded across the PRD, workplan, TODO list, and command runbooks inside `DOCS/`.

## Mission & Scope
- Ship a cross-platform Swift CLI (`docc2context`) that converts DocC bundles/archives into deterministic Markdown + link graph outputs for LLM consumption.
- Keep tooling offline-friendly, portable to Linux + macOS, and constrained to Swift 5.9+ plus standard Foundation/SwiftPM dependencies.

## Execution Principles
1. **Follow the Phased Workplan** – Prioritize tasks according to `DOCS/workplan.md` (phases A–D). When picking work, reference `DOCS/todo.md` for ready items and respect their dependency chains.
2. **Use Command Runbooks** – Drive task lifecycle with the markdown runbooks under `DOCS/COMMANDS/` (SELECT_NEXT → START → STATE, plus BUG/FIX/NEW/ARCHIVE). Treat them as templates for documenting intent, progress, and closure.
3. **Document Active Work** – Maintain per-task notes inside `DOCS/INPROGRESS/` linking back to PRD IDs (A1–D4). Archive finished efforts to `DOCS/TASK_ARCHIVE/` with summaries.
4. **Plan from the PRD** – Align scope, acceptance criteria, and success metrics with `DOCS/PRD/docc2context_prd.md` and phase-specific supplements. Every change should trace back to a PRD requirement or explicit TODO entry.
5. **Test-Driven Development** – Write failing tests first for CLI contracts, bundle handling, parsing, Markdown generation, and determinism checks. Use XCTest, snapshot fixtures, and deterministic hash comparisons per the PRD.
6. **Determinism & Quality Gates** – Ensure repeated runs on identical inputs produce identical outputs. CI must execute `swift test`, determinism checks, coverage thresholds, and release gate scripts before packaging.
7. **Fixture Discipline** – Store DocC sample bundles under `Fixtures/` with provenance notes; use them for parser/generator tests without relying on network access.
8. **Error Handling & Logging** – Provide descriptive CLI errors (`--help`, exit codes) and structured logging covering detection, extraction, parsing, generation, and summary counts. Warn (don’t crash) on recoverable anomalies like missing optional assets or locale fallbacks.
9. **Security & Safety** – Reject invalid bundles, prevent path traversal during archive extraction, sanitize temporary directories, and avoid loading huge media files fully into memory.

## Coordination Checklist
- Update TODO/INPROGRESS/ARCHIVE documents whenever task status changes.
- Record decisions, blockers, and validation evidence in the relevant INPROGRESS file and reference them from STATE/ARCHIVE updates.
- Keep README and release documentation in sync with shipped CLI behavior, especially usage flags, fixtures, and automation scripts.
