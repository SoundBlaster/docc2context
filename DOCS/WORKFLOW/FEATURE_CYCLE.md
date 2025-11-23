# SYSTEM PROMPT: Complete Feature Development Cycle

## 🔄 WORKFLOW OVERVIEW
Execute the complete lifecycle for developing and delivering a feature in the docc2context project: from selecting the next priority task, through full implementation with tests, to final archival and documentation. This workflow ensures consistency, quality, and proper tracking throughout the development process.

## 🎯 GOAL
Successfully deliver a complete, tested, and documented feature by:
1. Selecting the highest-priority task from the TODO queue
2. Planning and documenting the implementation approach
3. Implementing the feature with comprehensive test coverage
4. Verifying all quality gates pass (tests, CI, determinism)
5. Archiving the completed work with proper documentation

This workflow represents the standard development cadence for docc2context features.

---

## 🔗 REFERENCE MATERIALS
- [PRD](../PRD/docc2context_prd.md) for feature requirements and acceptance criteria
- [Workplan](../workplan.md) for phase dependencies and sequencing
- [TODO](../todo.md) for current task queue and priorities
- [Phase Checklist Index](../PRD/phases.md) for phase-specific requirements
- [TASK_ARCHIVE](../TASK_ARCHIVE/) for patterns from completed work

---

## 📋 ORCHESTRATION STEPS

### Step 1: Task Selection & Planning
**Command:** [SELECT_NEXT](../COMMANDS/SELECT_NEXT.md)

**Actions:**
1. Review current TODO queue against PRD priorities
2. Check for any blocking dependencies or prerequisites
3. Evaluate workload and select appropriately-sized task
4. Create INPROGRESS documentation with:
   - Task objective and scope
   - PRD references and acceptance criteria
   - Test plan outline
   - Known dependencies
5. Mark task as in-progress in TODO

**Validation:**
- `DOCS/INPROGRESS/[TaskID]_[TaskName].md` exists
- Task is marked in-progress in `DOCS/todo.md`
- No conflicts with other team members' work
- Prerequisites are satisfied

**Output:** Task selected, planned, and ready for implementation.

---

### Step 2: Full Implementation
**Command:** [START](../COMMANDS/START.md)

**Actions:**
1. **TDD Red Phase:**
   - Write failing tests that validate PRD acceptance criteria
   - Cover both positive and negative test cases
   - Include snapshot/determinism tests if applicable
   - Verify tests fail with expected error messages
   - **DO NOT commit failing tests**

2. **TDD Green Phase:**
   - Implement minimum code to make all tests pass
   - Follow existing code patterns and architecture
   - Update parsers, CLI, Markdown generators as needed
   - Run `swift test` frequently to track progress

3. **TDD Refactor Phase:**
   - Clean up implementation (remove duplication, improve naming)
   - Add comments for complex logic
   - Update public API documentation if needed
   - Ensure code follows project conventions

4. **Validation:**
   - Run full test suite: `swift test`
   - Verify no regressions in existing tests
   - Check determinism if applicable
   - Ensure CI would pass (no warnings, formatting issues)

**Quality Gates (ALL must pass):**
- ✅ All new tests pass
- ✅ All existing tests still pass
- ✅ Implementation satisfies PRD acceptance criteria
- ✅ Code is clean, documented, and review-ready
- ✅ Local CI checks pass

**Output:** Complete, tested feature ready for archival.

---

### Step 3: Finalization & Archival
**Command:** [ARCHIVE](../COMMANDS/ARCHIVE.md)

**Actions:**
1. **Final Documentation:**
   - Update INPROGRESS note with completion summary
   - Document any lessons learned or gotchas
   - Note any follow-up tasks discovered
   - Update README or API docs if public interface changed

2. **Tracking Updates:**
   - Mark task complete in `DOCS/todo.md`
   - Move INPROGRESS note to `DOCS/TASK_ARCHIVE/`
   - Update workplan if phase objectives were met
   - Check off relevant PRD checklist items

3. **Knowledge Capture:**
   - Archive includes: objective, approach, outcomes, lessons
   - Link to relevant commits/PRs
   - Document any edge cases or special considerations
   - Record test coverage details

**Validation:**
- Task moved from INPROGRESS to TASK_ARCHIVE
- TODO reflects completion
- PRD/workplan updated appropriately
- All documentation is current

**Output:** Feature fully delivered, documented, and archived.

---

## ✅ EXPECTED OUTPUT

After completing this workflow, you should have:

### Code Artifacts:
- ✅ Complete feature implementation in codebase
- ✅ Comprehensive test coverage (unit, snapshot, determinism)
- ✅ All tests passing locally and in CI
- ✅ Clean, documented, review-ready code

### Documentation Artifacts:
- ✅ `DOCS/TASK_ARCHIVE/[TaskID]_[TaskName].md` with complete history
- ✅ `DOCS/todo.md` updated (task marked complete)
- ✅ `DOCS/workplan.md` updated if phase objectives met
- ✅ `DOCS/PRD/phases.md` checklist items marked off
- ✅ Updated README/API docs if public interfaces changed

### Quality Indicators:
- ✅ PRD acceptance criteria satisfied
- ✅ No regressions in existing functionality
- ✅ Code follows project conventions
- ✅ Ready for code review and merge

---

## 🚨 COMMON PITFALLS

### ❌ Anti-pattern: Stopping at Planning
**Wrong:** Running SELECT_NEXT and treating the INPROGRESS doc as the deliverable.
**Right:** SELECT_NEXT is just Step 1. Must proceed through START and ARCHIVE.

### ❌ Anti-pattern: Committing Failing Tests
**Wrong:** Writing red tests and committing them "for visibility."
**Right:** Follow full TDD cycle (red → green → refactor) before committing.

### ❌ Anti-pattern: Partial Implementation
**Wrong:** Implementing part of the feature and "saving the rest for later."
**Right:** Break large tasks into smaller completable units in SELECT_NEXT.

### ❌ Anti-pattern: Skipping Tests
**Wrong:** Implementing code without corresponding test coverage.
**Right:** TDD mandates tests first, then implementation.

### ❌ Anti-pattern: Forgetting Documentation
**Wrong:** Archiving task without updating TODO, PRD, or workplan.
**Right:** Complete documentation is part of "done."

---

## 🔀 WORKFLOW VARIATIONS

### Fast-Track for Trivial Tasks
For very small tasks (single-line fixes, typos):
1. Quickly verify task in TODO
2. Implement + test in one step
3. Archive immediately
4. Skip INPROGRESS doc if truly trivial

### Large Feature Breakdown
If task seems too large during SELECT_NEXT:
1. **STOP** before starting implementation
2. Break into smaller sub-tasks in TODO
3. Run SELECT_NEXT on first sub-task
4. Complete each sub-task through full cycle
5. Final sub-task ARCHIVE can reference the full feature

---

## 🔗 RELATED WORKFLOWS
- [BUG_CYCLE](./BUG_CYCLE.md) - When bugs are discovered during feature work
- [BLOCKED_RECOVERY](./BLOCKED_RECOVERY.md) - When dependencies block progress
- Use [STATE](../COMMANDS/STATE.md) mid-workflow to communicate progress during handoffs

---

## 📝 EXAMPLE EXECUTION

```
1. SELECT_NEXT identifies task "B1.2 - Add snapshot testing for Symbol docs"
   → Creates DOCS/INPROGRESS/B1.2_SymbolSnapshots.md
   → Marks task in-progress in TODO

2. START implements the feature:
   → Writes failing snapshot tests
   → Implements Symbol documentation generator
   → Makes tests pass
   → Runs swift test (all green)
   → Updates INPROGRESS with status

3. ARCHIVE finalizes delivery:
   → Moves INPROGRESS to TASK_ARCHIVE
   → Marks B1.2 complete in TODO
   → Checks off PRD Phase B items
   → Documents lessons learned
```

**Result:** Complete, tested Symbol snapshot feature delivered with full documentation trail.
