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
- ✅ Adopted Swift 5.9 toolchain and confirmed it is available inside the container image.
- ✅ Scaffolded a multi-target SwiftPM workspace with an executable target (`docc2context`) and reusable library target (`docc2contextCore`).
- ✅ Added GitHub Actions workflow (`.github/workflows/ci.yml`) that runs `swift test --enable-code-coverage` on Ubuntu and macOS using the Swift 5.9 toolchain.
- ✅ Implemented a placeholder executable + core type so CI can compile immediately; real functionality will follow in downstream tasks.
- ⏳ Still need to expand README usage docs once richer CLI behavior ships (tracked for later).

## Next Steps / Subtasks
1. ✅ Scaffold Swift package via `swift package init --type executable` then adjust to multi-target layout (CLI + library + tests).
2. ✅ Add placeholder unit test to validate package wiring; future tasks (A2) will expand harness utilities.
3. ✅ Author `.github/workflows/ci.yml` running `swift test` on Ubuntu & macOS, with environment setup mirroring PRD requirements.
4. ⏳ Update README usage section once CLI target exists (may fall under subsequent documentation tasks but track as follow-up).
5. 🔄 Continue following `COMMANDS/STATE.md` to capture future implementation notes and blockers.
