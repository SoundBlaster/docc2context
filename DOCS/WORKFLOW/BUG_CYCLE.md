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

Document observed behavior, reproduction steps, severity, and affected components. Create INPROGRESS doc with complete context.

**Output:** Bug documented in `DOCS/INPROGRESS/BUG_[ShortDescription].md`

---

### Step 2: Fix Planning
**Command:** [FIX](../COMMANDS/FIX.md)

Perform root cause analysis, design minimal fix, plan regression tests, assess impact. Update INPROGRESS with fix strategy.

**Output:** Clear fix plan with root cause identified and test strategy defined.

---

### Step 3: Fix Implementation
**Command:** [START](../COMMANDS/START.md)

Implement fix using TDD: write regression test (red), fix the bug (green), refactor and validate. All tests must pass.

**Output:** Bug fixed with regression test coverage and all tests passing.

---

### Step 4: Archival & Knowledge Capture
**Command:** [ARCHIVE](../COMMANDS/ARCHIVE.md)

Archive bug resolution with root cause explanation, prevention strategy, and lessons learned. Update TODO and tracking docs.

**Output:** Bug archived in `DOCS/TASK_ARCHIVE/` with prevention measures documented.

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
