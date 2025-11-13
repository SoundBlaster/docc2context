# SYSTEM PROMPT: Record docc2context Bug

## 🧩 PURPOSE
Capture regressions, defects, or quality gaps discovered while building the docc2context CLI so they can be triaged, fixed, and prevented from resurfacing.

---

## 🎯 GOAL
Every bug entry should:
- explain how the issue manifests (input, command, observed output),
- point to relevant fixtures or logs,
- tie back to PRD acceptance criteria or TODO items that are now at risk,
- generate actionable work (usually a new test-first task added to `DOCS/todo.md`).

---

## 🔗 REFERENCE MATERIALS
- [PRD](../PRD/docc2context_prd.md) — identify which requirement is violated.
- [Workplan](../workplan.md) — determine which phase is affected.
- [TODO list](../todo.md) — see if there is already a task covering the bug or add one.
- [`DOCS/INPROGRESS/`](../INPROGRESS) — include links if the bug surfaced during active work.

---

## ⚙️ EXECUTION STEPS
1. **Document Reproduction Steps**
   - Input path/fixture, CLI flags, environment (OS, Swift version).
   - Command output, logs, and exit codes.
   - Whether the issue is deterministic.
2. **Describe Expected vs Actual**
   - Quote the PRD requirement or spec snippet describing expected behavior.
   - Explain what actually happened and impact (crash, incorrect Markdown, nondeterministic hash, etc.).
3. **Assess Severity & Priority**
   - P0: blocks conversion or violates determinism.
   - P1: missing feature promised in PRD but with workaround.
   - P2: polish or docs misalignment.
4. **Create Tracking Artifact**
   - Add a `BUG_{date}_{slug}.md` note to `DOCS/INPROGRESS/` if investigation is underway.
   - Insert a checkbox item in `DOCS/todo.md` referencing the bug note and severity.
5. **Notify Stakeholders**
   - Mention in the next STATE report or README changelog if user-facing.
   - If immediate fix is needed, run [FIX](./FIX.md) workflow.

---

## ✅ EXPECTED OUTPUT
- Reproducible documentation of the defect.
- TODO entry (or update) representing the fix work.
- Links between PRD requirements and the bug for auditing.
