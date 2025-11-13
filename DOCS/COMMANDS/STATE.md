# SYSTEM PROMPT: Report docc2context Project State

## 🧩 PURPOSE
Provide a snapshot of current progress, blockers, and next steps for the docc2context CLI by synthesizing information across PRD, workplan, TODO, and archive documents.

---

## 🎯 GOAL
Deliver a shareable status update that:
- quantifies progress per phase (A–D) using counts from TODO and ARCHIVE files,
- lists active efforts inside `DOCS/INPROGRESS/`,
- surfaces risks or decisions needing attention,
- recommends what to do next (link to [SELECT_NEXT](./SELECT_NEXT.md)).

---

## 🔗 REFERENCE MATERIALS
- [PRD](../PRD/docc2context_prd.md) tables for total tasks per phase.
- [Workplan](../workplan.md) for sequencing notes.
- [TODO list](../todo.md) for remaining and in-progress tasks.
- [`DOCS/INPROGRESS/`](../INPROGRESS) files for ongoing work.
- [`DOCS/TASK_ARCHIVE/ARCHIVE_SUMMARY.md`](../TASK_ARCHIVE/ARCHIVE_SUMMARY.md) for completed counts.

---

## 📊 REPORT STRUCTURE
1. **Overview** — one paragraph summarizing objective, current focus, and health.
2. **Phase Progress Table** — e.g., `Phase A: 0/4 complete (A1–A4)` referencing TODO/Archive counts.
3. **Active Tasks** — list each INPROGRESS file with owner (if known), status, blockers, and next milestone.
4. **Risks & Blockers** — anything preventing forward movement (missing fixtures, unverified determinism, etc.).
5. **Metrics** — commands last run (`swift test`, lint, determinism) and their dates if available.
6. **Next Recommendations** — pointer to highest-value task plus prerequisites.

---

## ⚙️ EXECUTION STEPS
1. **Collect Data**
   - Count checked vs unchecked boxes in `DOCS/todo.md` per phase.
   - Count archived folders or summary entries to infer completed tasks.
   - Review INPROGRESS notes for current status and evidence.
2. **Normalize Terminology**
   - Use PRD identifiers (A1…D4) whenever referencing work to avoid ambiguity.
3. **Draft the Report**
   - Use Markdown headings aligning with the structure above.
   - Include bullet lists and code blocks where data or commands were run.
4. **Share & Store**
   - Place the report in the relevant INPROGRESS note or a new file (`STATE_{date}.md`).
   - Optionally add a short excerpt to README or project log if major milestone reached.

---

## ✅ EXPECTED OUTPUT
- Markdown status report referencing all relevant documents.
- Updated TODO/workplan if the state review uncovered mismatches.
- Clarity on what [START](./START.md) or [SELECT_NEXT](./SELECT_NEXT.md) should target next.
