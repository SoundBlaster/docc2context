# SYSTEM PROMPT: Start docc2context Task

## ⚠️ CRITICAL: UNDERSTAND THE DIFFERENCE
- **[SELECT_NEXT](./SELECT_NEXT.md)** = Choose a task and write planning documentation ONLY
- **START** (this command) = FULLY IMPLEMENT the task from start to finish

**If you are only writing documentation or only writing tests, YOU ARE DOING IT WRONG.**

This command requires COMPLETE implementation: tests + code + passing CI. No half-measures.

---

## 🧩 PURPOSE
**EXECUTE AND COMPLETE** a selected task from start to finish: write failing tests, implement the code to make them pass, verify CI passes, and prepare for archival. This is NOT a planning command — planning happens in [SELECT_NEXT](./SELECT_NEXT.md). START means **SHIP THE FEATURE**.

---

## 🎯 GOAL
Complete the FULL implementation cycle for the selected task:
1. **Write failing tests first** (TDD red phase) — but DO NOT commit only red tests
2. **Implement the code** to make tests pass (TDD green phase)
3. **Verify ALL tests pass** including CI pipelines
4. **Refactor if needed** (TDD refactor phase)
5. **Ensure the feature is complete and shippable**

Key principles:
- Reference authoritative docs ([PRD](../PRD/docc2context_prd.md), [workplan](../workplan.md), [todo](../todo.md))
- Follow TDD: red → green → refactor, but NEVER stop at red
- Respect existing `DOCS/INPROGRESS/` assignments
- Deliver working, tested code that passes CI

---

## 📋 EXAMPLES

### ✅ CORRECT Usage
```
Agent: "I'll implement task B1.2 - Add snapshot testing for Symbol documentation.
1. First, I'll write failing snapshot tests for Symbol docs
2. Then implement the Symbol documentation generator
3. Verify tests pass and CI is green
4. Update tracking docs"

[Agent proceeds to write tests, implement code, run swift test, verify everything passes, commit]
```

### ❌ INCORRECT Usage (Anti-patterns)

**Anti-pattern 1: Only writing documentation**
```
Agent: "I've created DOCS/INPROGRESS/B1.2_SymbolSnapshots.md with the plan.
Task complete!" ❌ WRONG - No code was written!
```

**Anti-pattern 2: Only writing tests**
```
Agent: "I've written failing tests for Symbol snapshots. They're red as expected.
Committing..." ❌ WRONG - Tests must be made green before commit!
```

**Anti-pattern 3: Stopping at planning**
```
Agent: "I've analyzed the task and here's what needs to be done: [list].
Ready to proceed when you are." ❌ WRONG - Just do it, don't ask!
```

**Anti-pattern 4: Implementation without tests**
```
Agent: "I've implemented the Symbol documentation generator. Done!"
❌ WRONG - Where are the tests?
```

### 🔧 Handling Large Tasks
If a task seems too large to complete in one session:
1. **STOP** - Don't start the task yet
2. Break it down into smaller sub-tasks in `DOCS/todo.md`
3. Run [SELECT_NEXT](./SELECT_NEXT.md) on the first sub-task
4. Then run START on that smaller piece
5. Each sub-task should be completable with tests + code + green CI

---

## 🔗 REFERENCE MATERIALS
- [PRD](../PRD/docc2context_prd.md) acceptance criteria for the chosen phase.
- [Phase Checklist Index](../PRD/phases.md) for the authoritative checkbox list tied to each phase.
- [Workplan](../workplan.md) for sequencing and dependency notes.
- [TODO list](../todo.md) entry describing prerequisites.
- Any existing `DOCS/TASK_ARCHIVE` entries for similar work (reusable lessons learned).

---

## 🔧 PRE-REQUISITE: Swift Environment Setup

**BEFORE implementing ANY task that requires `swift build` or `swift test`:**

1. **Verify Swift is Installed**
   ```bash
   swift --version
   ```

2. **If Swift is Missing:**
   - Follow setup procedure in [DOCS/RULES/SWIFT_SETUP.md](../RULES/SWIFT_SETUP.md)
   - Or run automated setup script provided in that document
   - Verify installation: `swift --version` should show Swift 6.0.3

3. **Environment Check**
   - Confirm PATH includes Swift: `echo $PATH | grep swift`
   - Test compilation: `swift build` (should complete without errors)
   - Test suite: `swift test` (should report pass/skip stats)

**Reference:** [DOCS/RULES/SWIFT_SETUP.md](../RULES/SWIFT_SETUP.md) — Complete Swift installation and troubleshooting guide

---

## ⚙️ EXECUTION STEPS

### Phase 1: Planning & Setup (Quick Review)
1. **Review Task Context**
   - Inspect `DOCS/INPROGRESS/` for the task note created by [SELECT_NEXT](./SELECT_NEXT.md)
   - Confirm task is not owned by another teammate
   - Verify prerequisites in `DOCS/todo.md` are satisfied
   - If INPROGRESS note doesn't exist, create it with: _Objective_, _PRD references_, _Test plan_, _Dependencies_

### Phase 2: TDD Red — Write Failing Tests
2. **Author Failing Tests**
   - Create or update test files (XCTest, snapshot tests, determinism checks)
   - Write specific test cases that validate the acceptance criteria from PRD
   - Run tests locally to confirm they FAIL with expected error messages
   - **CRITICAL**: Do NOT commit at this stage — red tests alone break CI

### Phase 3: TDD Green — Implement Code
3. **Implement Feature Code**
   - Write the minimal code needed to make all new tests pass
   - Follow existing code patterns and architecture
   - Update fixtures, parsers, CLI logic, or Markdown generators as needed
   - Run `swift test` frequently to verify progress

4. **Verify All Tests Pass Locally**
   - Run full test suite: `swift test`
   - Run determinism checks if applicable
   - Ensure no existing tests were broken
   - Fix any regressions immediately

### Phase 4: TDD Refactor — Polish & Verify
5. **Refactor & Document**
   - Clean up code (remove duplication, improve naming, add comments)
   - Update relevant documentation if public APIs changed
   - Ensure code follows project conventions

6. **Final Validation**
   - Run complete test suite one more time
   - Verify CI pipeline will pass (check for common issues: formatting, warnings, etc.)
   - Update INPROGRESS note with completion status

### Phase 5: Finalize
7. **Update Tracking Documents**
   - Mark task as complete in `DOCS/todo.md`
   - Update INPROGRESS note with final status and outcomes
   - Note any follow-up tasks discovered during implementation

---

## ✅ EXPECTED OUTPUT

### Deliverables (ALL required, not optional):
1. **Working, Tested Code**
   - Complete feature implementation that satisfies PRD acceptance criteria
   - All tests passing (both new and existing)
   - Code follows project conventions and patterns

2. **Comprehensive Test Coverage**
   - New test cases covering the implemented functionality
   - Tests validate acceptance criteria from PRD
   - Both positive and negative test cases where applicable
   - Snapshot/determinism tests if required by the feature

3. **CI Verification**
   - Local test suite passes: `swift test` ✅
   - No warnings or errors that would break CI
   - Determinism checks pass if applicable

4. **Documentation Updates**
   - INPROGRESS note updated with completion status
   - `DOCS/todo.md` marked complete or moved to appropriate section
   - Code comments added for complex logic
   - README/API docs updated if public interface changed

### Quality Gates (must pass before considering task complete):
- ✅ All new tests pass
- ✅ All existing tests still pass (no regressions)
- ✅ Code review-ready (clean, documented, follows conventions)
- ✅ Ready for archival via [ARCHIVE](./ARCHIVE.md) command

### NOT Acceptable:
- ❌ Only tests without implementation
- ❌ Only implementation without tests
- ❌ Red/failing tests (even if "by design")
- ❌ Partial implementation "to be finished later"
- ❌ Breaking existing tests
- ❌ Code that would fail CI pipelines

---

## 🔄 RELATED COMMANDS
- [SELECT_NEXT](./SELECT_NEXT.md) to choose the task before starting.
- [STATE](./STATE.md) to summarize progress mid-stream.
- [ARCHIVE](./ARCHIVE.md) when work is complete.
