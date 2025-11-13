# docc2context Command Suite

The `DOCS/COMMANDS` directory mirrors the workflow described in the docc2context PRD, workplan, and TODO list. Each command is a self-contained runbook that keeps task selection, execution, and archival consistent with the sources of truth inside `DOCS/PRD`, `DOCS/workplan.md`, `DOCS/todo.md`, `DOCS/INPROGRESS/`, and `DOCS/TASK_ARCHIVE/`.

| Command | Primary Intent | Typical Trigger |
| --- | --- | --- |
| [SELECT_NEXT](./SELECT_NEXT.md) | Evaluate the PRD priorities, workplan phases, and TODO queue to choose the next task. | At the end of a work session or when switching focus to a fresh item. |
| [START](./START.md) | Move a chosen task into motion by setting scope, success criteria, and INPROGRESS documentation. | Immediately after SELECT_NEXT confirms the target. |
| [STATE](./STATE.md) | Publish a progress snapshot referencing INPROGRESS notes, TODO updates, and any blockers. | During handoffs, daily syncs, or before opening a PR. |
| [BUG](./BUG.md) | Capture regressions or doc mismatches uncovered while working through the PRD acceptance criteria. | Whenever unexpected behavior or doc drift is observed. |
| [FIX](./FIX.md) | Describe the remediation plan for an acknowledged bug, linking tests, PRD deltas, and TODO items. | Right after filing a BUG and before touching implementation. |
| [NEW](./NEW.md) | Introduce net-new scope discovered during execution, ensuring it lands on the TODO list with PRD context. | When emerging requirements surface outside the current plan. |
| [ARCHIVE](./ARCHIVE.md) | Close the loop on completed work, updating TODO, INPROGRESS, and TASK_ARCHIVE entries. | After a task's code merges and documentation/tests satisfy acceptance criteria. |

Use these command files as templates when updating the project log so every change references the same canonical documents and phase sequencing.
