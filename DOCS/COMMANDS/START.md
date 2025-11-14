# SYSTEM PROMPT: Start docc2context Task

## 🧩 PURPOSE
Move a selected task from the TODO list into execution with a laser focus on creating failing tests first, then writing the code that satisfies them, without re-litigating tasks that are already represented inside `DOCS/INPROGRESS/`.

---

## 🎯 GOAL
Establish a repeatable kick-off ritual so every effort:
- references the authoritative docs ([PRD](../PRD/docc2context_prd.md), [workplan](../workplan.md), [todo](../todo.md)),
- frames the very next failing XCTest/snapshot/determinism check that will drive implementation,
- records what "done" means inside `DOCS/INPROGRESS/` before touching Swift files,
- respects existing `DOCS/INPROGRESS/` assignments by adding new work rather than rewriting someone else’s plan.

---

## 🔗 REFERENCE MATERIALS
- [PRD](../PRD/docc2context_prd.md) acceptance criteria for the chosen phase.
- [Phase Checklist Index](../PRD/phases.md) for the authoritative checkbox list tied to each phase.
- [Workplan](../workplan.md) for sequencing and dependency notes.
- [TODO list](../todo.md) entry describing prerequisites.
- Any existing `DOCS/TASK_ARCHIVE` entries for similar work (reusable lessons learned).

---

## ⚙️ EXECUTION STEPS
1. **Review SELECT_NEXT Output**
   - Inspect `DOCS/INPROGRESS/` for the freshly created task note from running [SELECT_NEXT](./SELECT_NEXT.md).
   - Confirm the note captures the task ID/slug and explicitly states it is available; if another teammate already owns it, stop here.
2. **Confirm Selection**
   - Verify the task is recorded in `DOCS/todo.md` and not currently assigned or in conflict with another INPROGRESS entry.
   - If prerequisites remain unchecked, either complete them first or capture blocking rationale inside the task note before proceeding.
3. **Create an INPROGRESS Note**
   - File name pattern: `DOCS/INPROGRESS/{TaskID}_{Slug}.md`.
   - Include sections: _Objective_, _Relevant PRD paragraphs_, _First Failing Test to Author_, _Dependencies_, _Blocking Questions_.
   - Paste a checklist of sub-steps emphasizing test/code creation (e.g., "write failing CLI test", "expand fixture", "implement parser to satisfy new assertions").
4. **Define Validation Plan**
   - Point to commands that must run (`swift test`, determinism script, etc.) and describe the exact new test names or fixtures being added.
   - Note fixture inputs and expected outputs for quick reruns, including where new fixtures will be stored.
5. **Update TODO List**
   - Annotate the entry with "In Progress" or move it to a dedicated heading, linking back to the INPROGRESS file.
   - Explicitly mention the first failing test that will verify success so reviewers know work has moved beyond planning.
6. **Set Immediate Next Action**
   - Identify the precise test file/class/function that will be edited next and record it in the INPROGRESS note.
   - Document any coordination needs (e.g., fixture acquisition, dependency decisions) to unblock the test-first workflow.
7. **Begin Execution**
   - Once documentation and TODO updates are complete, immediately start writing the planned test or code that makes it pass.
   - Capture any deviations discovered during this kick-off inside the INPROGRESS note so the task remains traceable without rewriting existing assignments.

---

## ✅ EXPECTED OUTPUT
- New or updated Markdown file in `DOCS/INPROGRESS/` capturing scope, validation, and the specific failing test/code sequence that will start the work.
- Updated `DOCS/todo.md` reflecting the task’s active state, linking back to the INPROGRESS context, and noting the first test being authored.
- Optional README/PRD cross-links if the task clarifies requirements.
- Evidence that execution has begun (e.g., initial failing test commit, fixture scaffold, or other tangible progress tied to the immediate next action).

---

## 🔄 RELATED COMMANDS
- [SELECT_NEXT](./SELECT_NEXT.md) to choose the task before starting.
- [STATE](./STATE.md) to summarize progress mid-stream.
- [ARCHIVE](./ARCHIVE.md) when work is complete.
