# SYSTEM PROMPT: Select Next docc2context Task

## 🧩 PURPOSE
Identify the most appropriate next unit of work for the docc2context CLI by combining the PRD, the phase ordering captured in [DOCS/workplan.md](../workplan.md), and the ready list inside [DOCS/todo.md](../todo.md).

---

## 🎯 GOAL
Pick a task that keeps the conversion pipeline unblocked while upholding TDD and determinism guardrails:
- Respect **phase dependencies** (Foundation tasks before CLI behaviors, CLI behaviors before Markdown generation).
- Prefer **higher priority IDs** (A → B → C → D) unless the workplan explicitly calls out a blocker that must be cleared.
- Ensure **tests or fixtures** exist (or will be authored) before feature code is touched.
- Capture the decision in `DOCS/INPROGRESS/{task}.md` so momentum and context do not get lost.

---

## 🔗 REFERENCE MATERIALS
- [Product Requirements](../PRD/docc2context_prd.md) — canonical scope, acceptance criteria, and priority table.
- [Phase Checklist Index](../PRD/phases.md) — quick links to per-phase TODO trackers for current counts.
- [Workplan](../workplan.md) — ordered list of phases and responsibilities.
- [TODO list](../todo.md) — curated queue of actionable tasks and dependencies.
- [`DOCS/INPROGRESS/`](../INPROGRESS) — currently active tasks and research notes.
- [`DOCS/TASK_ARCHIVE/ARCHIVE_SUMMARY.md`](../TASK_ARCHIVE/ARCHIVE_SUMMARY.md) — recently completed items for velocity clues.

---

## 📐 SELECTION HEURISTICS
1. **Phase Integrity** — Do not begin Markdown generation (Phase C) until A and B deliverables required by the PRD are archived.
2. **Dependency Check** — Confirm TODO entry lists satisfied prerequisites. If not, add them to TODO or choose a different task.
3. **Testing First** — If a feature is implementation-heavy, queue a testing/failing-spec task before the implementation task.
4. **Coverage Balance** — Alternate between infrastructure (Phases A/B) and product output (Phases C/D) so the CLI remains runnable while features evolve.
5. **Doc Sync** — Prefer tasks whose completion will unblock updates to README or docs, maintaining project visibility.

---

## ⚙️ EXECUTION STEPS
1. **Scan Current State**
   - Review `DOCS/todo.md` "Ready to Start" plus "Under Consideration" sections.
   - Inspect `DOCS/INPROGRESS/` for existing work that might already satisfy part of the requirement.
   - Skim `DOCS/TASK_ARCHIVE/ARCHIVE_SUMMARY.md` to confirm prerequisites truly landed.
2. **Cross-Reference PRD & Workplan**
   - Map the candidate task ID back to PRD sections (Phase tables) to verify acceptance criteria.
   - Ensure the workplan does not list unmet predecessors.
3. **Validate Resourcing**
   - Confirm required fixtures, docs, or tooling exist. If missing, create a precursor TODO entry.
4. **Record the Decision**
   - Append a checkbox entry in `DOCS/todo.md` marking the task as "In Progress" or move it under a dedicated heading.
   - Create `DOCS/INPROGRESS/{TaskID}_{ShortName}.md` with scope, success metrics, and links to reference materials.
5. **Plan Next Steps**
   - Identify expected tests, fixtures, or scripts needed before coding starts.
   - If work spans multiple sessions, add reminders or subtasks under the new INPROGRESS file.

---

## ✅ EXPECTED OUTPUT
- Markdown note inside `DOCS/INPROGRESS/` describing the newly selected task.
- Updated checkbox state or note inside `DOCS/todo.md` indicating who/what is active.
- Optional update to README or PRD annotations if selection exposes gaps.

---

## 🔄 RELATED COMMANDS
- [START](./START.md) — to kick off execution once the task is selected.
- [STATE](./STATE.md) — to summarize progress before/after selection.
- [ARCHIVE](./ARCHIVE.md) — to close the loop once the task is complete.
