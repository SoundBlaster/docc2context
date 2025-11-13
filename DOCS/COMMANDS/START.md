# SYSTEM PROMPT: Start docc2context Task

## 🧩 PURPOSE
Move a selected task from the TODO list into execution with clear scope, success criteria, and TDD checkpoints.

---

## 🎯 GOAL
Establish a repeatable kick-off ritual so every effort:
- references the authoritative docs ([PRD](../PRD/docc2context_prd.md), [workplan](../workplan.md), [todo](../todo.md)),
- defines how failing tests or fixtures will be produced,
- records what "done" means inside `DOCS/INPROGRESS/` before any Swift files are changed.

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
   - Ensure the note captures the task ID/slug and any triage observations so START picks up exactly where SELECT_NEXT left off.
2. **Confirm Selection**
   - Verify the task is recorded in `DOCS/todo.md` and not currently assigned.
   - If prerequisites remain unchecked, either complete them first or capture blocking rationale inside the task note.
3. **Create an INPROGRESS Note**
   - File name pattern: `DOCS/INPROGRESS/{TaskID}_{Slug}.md`.
   - Include sections: _Objective_, _Relevant PRD paragraphs_, _Test Plan_, _Dependencies_, _Blocking Questions_.
   - Paste a checklist of sub-steps (e.g., "write failing CLI test", "implement parser", "update README").
4. **Define Validation Plan**
   - Point to commands that must run (`swift test`, determinism script, etc.).
   - Note fixture inputs and expected outputs for quick reruns.
5. **Update TODO List**
   - Annotate the entry with "In Progress" or move it to a dedicated heading.
   - Link back to the new INPROGRESS file for context.
6. **Set Immediate Next Action**
   - Identify what will happen in the next working session (usually writing or updating tests).
   - Document any coordination needs (e.g., new fixture acquisition) in the INPROGRESS note.
7. **Begin Execution**
   - Once documentation and TODO updates are complete, explicitly commit to the next action by starting the planned work immediately.
   - Capture any deviations discovered during this kick-off inside the INPROGRESS note so the task remains traceable.

---

## ✅ EXPECTED OUTPUT
- New or updated Markdown file in `DOCS/INPROGRESS/` capturing scope, plan, validation, and the directive to start work now.
- Updated `DOCS/todo.md` reflecting the task’s active state and linking back to the INPROGRESS context.
- Optional README/PRD cross-links if the task clarifies requirements.
- Evidence that execution has begun (e.g., initial code/tests or other tangible progress tied to the immediate next action).

---

## 🔄 RELATED COMMANDS
- [SELECT_NEXT](./SELECT_NEXT.md) to choose the task before starting.
- [STATE](./STATE.md) to summarize progress mid-stream.
- [ARCHIVE](./ARCHIVE.md) when work is complete.
