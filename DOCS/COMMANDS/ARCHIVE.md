# SYSTEM PROMPT: Archive Completed docc2context Work

## 🧩 PURPOSE
Move finished tasks from [`DOCS/INPROGRESS/`](../INPROGRESS) into [`DOCS/TASK_ARCHIVE/`](../TASK_ARCHIVE) while updating the PRD/workplan artifacts so history, lessons, and velocity remain traceable.

---

## 🎯 GOAL
Ensure every archived task:
- satisfies the acceptance criteria in [DOCS/PRD/docc2context_prd.md](../PRD/docc2context_prd.md),
- records validation proof (e.g., `swift test`, determinism checks),
- updates the TODO/workplan to reflect new status,
- leaves a succinct record inside `ARCHIVE_SUMMARY.md` for future audits.

---

## 🔗 REFERENCE MATERIALS
- [PRD](../PRD/docc2context_prd.md) for acceptance checklists.
- [Workplan](../workplan.md) to update phase progress.
- [TODO list](../todo.md) for checkbox states and follow-on work.
- [`DOCS/INPROGRESS/{task}.md`](../INPROGRESS) containing session notes and remaining subtasks.
- [`DOCS/TASK_ARCHIVE/ARCHIVE_SUMMARY.md`](../TASK_ARCHIVE/ARCHIVE_SUMMARY.md) for chronology.

---

## ✅ PRE-ARCHIVE CHECKLIST
1. **Tests** — `swift test` passes locally; determinism/fixture scripts (if applicable) are green.
2. **Docs** — README or PRD updates referenced in the task note are merged; new behaviors documented.
3. **Artifacts** — Fixtures, snapshots, or scripts committed with deterministic paths.
4. **TODO Alignment** — Original entry in `DOCS/todo.md` shows all subtasks checked.
5. **In-Progress Notes** — Decisions and caveats captured so future maintainers understand trade-offs.

If any item is incomplete, pause archiving and return to START/STATE flows.

---

## ⚙️ EXECUTION STEPS
1. **Finalize INPROGRESS Note**
   - Summarize validation commands and their outputs.
   - List remaining follow-ups (if any) and convert them into TODO entries before archiving.
2. **Create Archive Folder**
   - Determine next sequential number based on existing directories in `DOCS/TASK_ARCHIVE/`.
   - Pattern: `{NN}_{TaskID}_{Slug}` (e.g., `01_A1_BootstrapCLI`).
   - `mkdir -p DOCS/TASK_ARCHIVE/{NN}_{TaskID}_{Slug}`
3. **Move Files**
   - Move the completed INPROGRESS note (and any supporting artifacts) into the new archive folder.
   - Keep `README.md` inside `DOCS/INPROGRESS/` untouched.
4. **Update Archive Summary**
   - Append an entry in `ARCHIVE_SUMMARY.md` including date, task ID, deliverables, and test evidence.
5. **Update Planning Docs**
   - Mark the task as complete in `DOCS/todo.md`.
   - If the completion advances a phase milestone, note it inside `DOCS/workplan.md` or the PRD tables.
6. **Surface Follow-Ups**
   - If new work was discovered, add TODO items and optionally run [SELECT_NEXT](./SELECT_NEXT.md).

---

## 📦 EXPECTED OUTPUTS
- Archived folder containing the final task notes and attachments.
- Updated TODO/workplan/PRD references reflecting completion.
- Archive summary entry for traceability.

---

## 🔄 RELATED COMMANDS
- [STATE](./STATE.md) — run before archiving to confirm readiness.
- [SELECT_NEXT](./SELECT_NEXT.md) — to pick the next priority item after archiving.
- [START](./START.md) — to initialize the next task.
