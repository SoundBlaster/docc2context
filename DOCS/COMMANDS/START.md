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
- [Workplan](../workplan.md) for sequencing and dependency notes.
- [TODO list](../todo.md) entry describing prerequisites.
- Any existing `DOCS/TASK_ARCHIVE` entries for similar work (reusable lessons learned).

---

## ⚙️ EXECUTION STEPS
1. **Confirm Selection**
   - Verify the task is recorded in `DOCS/todo.md` and not currently assigned.
   - If prerequisites remain unchecked, either complete them first or capture blocking rationale inside the task note.
2. **Create an INPROGRESS Note**
   - File name pattern: `DOCS/INPROGRESS/{TaskID}_{Slug}.md`.
   - Include sections: _Objective_, _Relevant PRD paragraphs_, _Test Plan_, _Dependencies_, _Blocking Questions_.
   - Paste a checklist of sub-steps (e.g., "write failing CLI test", "implement parser", "update README").
3. **Define Validation Plan**
   - Point to commands that must run (`swift test`, determinism script, etc.).
   - Note fixture inputs and expected outputs for quick reruns.
4. **Update TODO List**
   - Annotate the entry with "In Progress" or move it to a dedicated heading.
   - Link back to the new INPROGRESS file for context.
5. **Set Immediate Next Action**
   - Identify what will happen in the next working session (usually writing or updating tests).
   - Document any coordination needs (e.g., new fixture acquisition) in the INPROGRESS note.

---

## ✅ EXPECTED OUTPUT
- New or updated Markdown file in `DOCS/INPROGRESS/` capturing scope, plan, and validation.
- Updated `DOCS/todo.md` reflecting the task’s active state.
- Optional README/PRD cross-links if the task clarifies requirements.

---

## 🔄 RELATED COMMANDS
- [SELECT_NEXT](./SELECT_NEXT.md) to choose the task before starting.
- [STATE](./STATE.md) to summarize progress mid-stream.
- [ARCHIVE](./ARCHIVE.md) when work is complete.
