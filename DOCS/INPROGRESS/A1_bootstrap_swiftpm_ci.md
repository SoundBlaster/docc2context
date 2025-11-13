# A1 – Bootstrap Swift Package & CI Skeleton

## Scope & Acceptance Criteria
- Establish a Swift Package Manager workspace with `docc2context` CLI target, reusable library target, and XCTest bundle as outlined in PRD Phase A deliverable A1.
- Provide a GitHub Actions workflow that runs `swift test` on both Ubuntu and macOS runners to guarantee cross-platform coverage before Phase B begins.
- Ensure repository tooling remains offline-friendly (no extra dependencies beyond SwiftPM + Foundation) per PRD guardrails.

## Dependencies & Current State
- Prerequisites: none. This is the first Phase A task and unblocks A2 (test harness utilities) plus all downstream CLI work.
- Ready resources reviewed:
  - `DOCS/workplan.md` confirms A1 precedes all other phases.
  - `DOCS/todo.md` now tracks this task in the In Progress section.
  - `DOCS/TASK_ARCHIVE/` has no entries yet, so there are no conflicting historical decisions.

## Execution Notes & Open Questions
- Need to decide Swift tools version (target Swift 5.9 per PRD). Verify container image has matching toolchain or note deviation.
- Determine CLI target name (likely `docc2context`) and whether to add a shared library target for internal components.
- Define baseline GitHub Actions workflow with matrix for `ubuntu-latest` and `macos-latest`, caching SwiftPM artifacts for determinism and speed.
- Consider stubbing an initial executable that prints `--help` placeholder so CI can build before real features exist.

## Next Steps / Subtasks
1. Scaffold Swift package via `swift package init --type executable` then adjust to multi-target layout (CLI + library + tests).
2. Add placeholder unit test to validate package wiring; future tasks (A2) will expand harness utilities.
3. Author `.github/workflows/ci.yml` running `swift test` on Ubuntu & macOS, with environment setup mirroring PRD requirements.
4. Update README usage section once CLI target exists (may fall under subsequent documentation tasks but track as follow-up).
5. After package + CI land, run `COMMANDS/START.md` for implementation and keep this note updated with blockers/findings.
