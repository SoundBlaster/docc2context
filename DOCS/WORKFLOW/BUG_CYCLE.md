# SYSTEM PROMPT: Bug Discovery and Resolution Workflow

## 🔄 WORKFLOW OVERVIEW
Handle the complete lifecycle of bug discovery, diagnosis, and resolution in the docc2context project: from initial observation through root cause analysis, fix implementation with regression tests, to final archival. This workflow ensures bugs are properly documented, fixed comprehensively, and prevented from recurring.

## 🎯 GOAL
Successfully resolve a bug by:
1. Documenting the observed behavior and expected behavior
2. Analyzing root cause and planning the fix
3. Writing regression tests that fail before the fix
4. Implementing the fix to make tests pass
5. Archiving the resolution with lessons learned

This workflow prevents hasty fixes and ensures proper regression coverage.

---

## 🔗 REFERENCE MATERIALS
- [PRD](../PRD/docc2context_prd.md) for acceptance criteria and requirements
- [BUG Command](../COMMANDS/BUG.md) for bug documentation format
- [FIX Command](../COMMANDS/FIX.md) for fix planning template
- [START Command](../COMMANDS/START.md) for implementation guidance
- [ARCHIVE Command](../COMMANDS/ARCHIVE.md) for final documentation

---

## 📋 ORCHESTRATION STEPS

### Step 1: Bug Documentation
**Command:** [BUG](../COMMANDS/BUG.md)

**Actions:**
1. **Capture Observation:**
   - Document exact behavior observed
   - Record steps to reproduce
   - Note affected components/files
   - Identify which PRD acceptance criteria are violated

2. **Evidence Collection:**
   - Save error messages, stack traces, or incorrect output
   - Create minimal reproduction case if possible
   - Record environment details (Swift version, OS, etc.)
   - Check if issue exists in CI or only locally

3. **Initial Analysis:**
   - Assess severity (blocker, critical, normal, minor)
   - Determine if this blocks current work
   - Check if related to recent changes (git blame, recent commits)
   - Search TASK_ARCHIVE for similar past issues

4. **Documentation:**
   - Create `DOCS/INPROGRESS/BUG_[ShortDescription].md`
   - Include: observed vs expected, reproduction steps, affected files
   - Link to relevant PRD sections
   - Note any workarounds discovered

**Validation:**
- Bug is reproducible with documented steps
- Expected behavior is clearly defined
- Severity is appropriate
- INPROGRESS doc exists with complete context

**Output:** Bug fully documented and ready for fix planning.

---

### Step 2: Fix Planning
**Command:** [FIX](../COMMANDS/FIX.md)

**Actions:**
1. **Root Cause Analysis:**
   - Trace through code to identify where behavior diverges
   - Determine if bug is in logic, edge case handling, or data flow
   - Check if issue affects multiple code paths
   - Identify why existing tests didn't catch this

2. **Fix Design:**
   - Plan minimal change to resolve root cause
   - Avoid over-engineering or scope creep
   - Consider edge cases and similar scenarios
   - Identify if PRD needs clarification or update

3. **Test Strategy:**
   - Plan regression test that would catch this bug
   - Identify any related scenarios to test
   - Determine if existing tests need updates
   - Plan for determinism/snapshot tests if applicable

4. **Impact Assessment:**
   - Estimate scope of changes needed
   - Check for potential side effects
   - Review if fix might affect other features
   - Note any documentation updates required

5. **Update Documentation:**
   - Append fix plan to INPROGRESS bug doc
   - Add TODO entry for fix implementation
   - Link to related PRD sections
   - Note any PRD clarifications needed

**Validation:**
- Root cause is clearly identified
- Fix approach is minimal and targeted
- Test strategy covers the bug and similar cases
- Impact on other code is assessed
- TODO has actionable fix entry

**Output:** Clear fix plan ready for implementation.

---

### Step 3: Fix Implementation
**Command:** [START](../COMMANDS/START.md)

**Actions:**
1. **TDD Red Phase - Regression Tests:**
   - Write test that reproduces the bug (should FAIL)
   - Verify test fails with same error observed in bug report
   - Add tests for related edge cases
   - Document test intent clearly
   - **DO NOT commit failing tests**

2. **TDD Green Phase - Fix Implementation:**
   - Implement minimal code change to fix root cause
   - Make regression test pass
   - Ensure all existing tests still pass
   - Run full test suite: `swift test`

3. **TDD Refactor Phase - Polish:**
   - Clean up fix implementation
   - Add comments explaining non-obvious logic
   - Update related tests if needed
   - Ensure code follows project conventions

4. **Comprehensive Validation:**
   - Verify original reproduction steps no longer trigger bug
   - Run full test suite (all tests pass)
   - Test edge cases manually if needed
   - Check determinism if applicable
   - Verify CI would pass

5. **Documentation Updates:**
   - Update INPROGRESS doc with fix outcome
   - Note any surprises or lessons learned
   - Document if PRD clarification is needed
   - Mark fix complete in TODO

**Quality Gates (ALL must pass):**
- ✅ Regression test passes (reproduces and validates fix)
- ✅ All existing tests still pass
- ✅ Original bug reproduction steps no longer trigger issue
- ✅ No new bugs introduced
- ✅ Code is clean and documented

**Output:** Bug fixed with regression test coverage.

---

### Step 4: Archival & Knowledge Capture
**Command:** [ARCHIVE](../COMMANDS/ARCHIVE.md)

**Actions:**
1. **Complete Documentation:**
   - Finalize INPROGRESS doc with:
     - Root cause explanation
     - Fix approach taken
     - Why this wasn't caught earlier
     - Prevention strategy for similar bugs
   - Link to relevant commits

2. **Lessons Learned:**
   - Document what tests were missing
   - Note if coding patterns should change
   - Identify if review process needs adjustment
   - Record if documentation was misleading

3. **Tracking Updates:**
   - Move bug doc to TASK_ARCHIVE
   - Mark TODO items complete
   - Update PRD if clarifications needed
   - Note in workplan if pattern affects other work

4. **Prevention Measures:**
   - Consider if similar bugs exist elsewhere
   - Update test suites to prevent recurrence
   - Document gotchas in code comments
   - Share learnings with team if applicable

**Validation:**
- Bug moved from INPROGRESS to TASK_ARCHIVE
- Archive includes root cause and prevention strategy
- TODO reflects completion
- Any PRD updates are documented

**Output:** Bug resolved, documented, and archived with prevention measures.

---

## ✅ EXPECTED OUTPUT

After completing this workflow, you should have:

### Code Artifacts:
- ✅ Bug fix implemented in codebase
- ✅ Regression test preventing recurrence
- ✅ All tests passing (existing + new)
- ✅ Clean, documented fix

### Documentation Artifacts:
- ✅ `DOCS/TASK_ARCHIVE/BUG_[ShortDescription].md` with complete analysis
- ✅ Root cause documented
- ✅ Prevention strategy recorded
- ✅ Lessons learned captured
- ✅ TODO updated (bug marked fixed)

### Quality Indicators:
- ✅ Original bug no longer reproducible
- ✅ Regression tests prevent recurrence
- ✅ No new bugs introduced by fix
- ✅ Understanding of why bug occurred

---

## 🚨 COMMON PITFALLS

### ❌ Anti-pattern: Rushing to Fix
**Wrong:** Seeing a bug and immediately changing code without analysis.
**Right:** Document (BUG) → Plan (FIX) → Implement (START) → Archive.

### ❌ Anti-pattern: Symptom Fixing
**Wrong:** Fixing the visible symptom without finding root cause.
**Right:** Trace through code to identify actual source of problem.

### ❌ Anti-pattern: No Regression Tests
**Wrong:** Fixing code without adding test to prevent recurrence.
**Right:** Write failing test first, then fix to make it pass.

### ❌ Anti-pattern: Over-Engineering
**Wrong:** Using bug as excuse to refactor unrelated code.
**Right:** Minimal targeted fix for the specific issue.

### ❌ Anti-pattern: Inadequate Documentation
**Wrong:** Fixing and archiving without explaining root cause.
**Right:** Document why bug happened and how to prevent similar issues.

---

## 🔀 WORKFLOW VARIATIONS

### Critical Production Bug
If bug is blocking all work:
1. BUG doc can be minimal initially
2. Jump to FIX and START quickly
3. Backfill complete documentation during ARCHIVE
4. Prioritize getting fix merged

### Bug During Feature Work
If discovered while implementing a feature:
1. Use BUG to document
2. Assess if it blocks current feature
3. If blocking: pause feature, complete BUG_CYCLE, resume
4. If not blocking: queue as separate TODO item

### Documentation Bug
If bug is in docs/comments rather than code:
1. Still use BUG to document mismatch
2. FIX plan updates documentation
3. START updates docs (may skip tests if pure documentation)
4. ARCHIVE records alignment

---

## 🔗 RELATED WORKFLOWS
- [FEATURE_CYCLE](./FEATURE_CYCLE.md) - Return to after bug is fixed
- [BLOCKED_RECOVERY](./BLOCKED_RECOVERY.md) - If bug creates a blocker
- Use [STATE](../COMMANDS/STATE.md) to communicate bug impact during handoffs

---

## 📝 EXAMPLE EXECUTION

```
1. BUG discovers "Symbol links generate incorrect URLs"
   → Documents expected vs observed behavior
   → Records reproduction steps
   → Creates DOCS/INPROGRESS/BUG_SymbolLinkURLs.md

2. FIX analyzes root cause
   → Traces through SymbolLinkGenerator code
   → Identifies URL encoding logic bug
   → Plans minimal fix + regression tests
   → Updates INPROGRESS with fix strategy

3. START implements fix
   → Writes failing test with expected URL format
   → Fixes URL encoding in SymbolLinkGenerator
   → Verifies test now passes
   → Runs full test suite (all green)

4. ARCHIVE documents resolution
   → Moves to TASK_ARCHIVE/BUG_SymbolLinkURLs.md
   → Records root cause: missing URL encoding
   → Documents prevention: added URL validation tests
   → Marks TODO complete
```

**Result:** Symbol link bug resolved with regression test preventing future occurrence.
