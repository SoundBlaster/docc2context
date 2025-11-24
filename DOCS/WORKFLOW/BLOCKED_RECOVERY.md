# SYSTEM PROMPT: Blocked Task Recovery Workflow

## 🔄 WORKFLOW OVERVIEW
Attempt to unblock and resume previously blocked tasks. This workflow handles the process of checking blocked task status, attempting resolution, and either resuming work or pivoting to alternatives.

**Note:** The [BLOCK](../COMMANDS/BLOCK.md) command is used WITHIN other workflows (like FEATURE_CYCLE or BUG_CYCLE) when a blocker is discovered. This workflow starts AFTER a task is already blocked.

## 🎯 GOAL
For tasks already marked as BLOCKED:
1. Attempt to unblock the task with [UNBLOCK](../COMMANDS/UNBLOCK.md)
2. If successful → resume work with normal workflow
3. If unsuccessful → pivot to alternative work and retry periodically

This workflow ensures blocked work doesn't stall indefinitely and team time remains productive.

---

## 🔗 REFERENCE MATERIALS
- [UNBLOCK Command](../COMMANDS/UNBLOCK.md) for attempting to resolve blockers
- [BLOCK Command](../COMMANDS/BLOCK.md) for understanding how task was blocked
- [SELECT_NEXT Command](../COMMANDS/SELECT_NEXT.md) for finding alternative work
- [TODO](../todo.md) for blocked task status
- Task's `DOCS/INPROGRESS/[TaskID]_[TaskName].md` with blocker documentation

---

## 📋 ORCHESTRATION STEPS

### Prerequisite: Task is Already Blocked
This workflow assumes a task was previously blocked during execution using [BLOCK](../COMMANDS/BLOCK.md) command. Task is marked BLOCKED in TODO with documented blocker conditions in INPROGRESS.

---

### Step 1: Attempt Unblocking
**Command:** [UNBLOCK](../COMMANDS/UNBLOCK.md)

Review blocker documentation, assess if unblocking conditions are met, attempt resolution, and document current status.

**Output:** Clear determination whether task is unblocked or still blocked.

---

### Step 2a: If Successfully Unblocked → Resume Work

Update documentation to reflect unblocked status, then resume work via [FEATURE_CYCLE](./FEATURE_CYCLE.md) or [BUG_CYCLE](./BUG_CYCLE.md) depending on task type.

**Output:** Task resumed and completed through normal workflow.

---

### Step 2b: If Still Blocked → Pivot to Alternative Work

Document unsuccessful unblock attempt, use [SELECT_NEXT](../COMMANDS/SELECT_NEXT.md) to find alternative work, set re-evaluation schedule (daily/weekly/bi-weekly based on priority).

**Output:** Alternative work selected, blocked task remains tracked with retry schedule.

---

## ✅ EXPECTED OUTPUT

### If Successfully Unblocked:
- ✅ Task marked as no longer blocked in TODO
- ✅ INPROGRESS updated with resolution details
- ✅ Work resumed via appropriate workflow (FEATURE_CYCLE/BUG_CYCLE)
- ✅ Blocker resolution documented with timeline

### If Still Blocked:
- ✅ Unblock attempt documented in INPROGRESS
- ✅ Updated blocker status and timeline
- ✅ Alternative work selected via SELECT_NEXT
- ✅ Re-evaluation schedule established
- ✅ Productive work continues on unblocked tasks

---

## 🚨 COMMON PITFALLS

### ❌ Anti-pattern: Passive Waiting
**Wrong:** Marking task blocked and never attempting UNBLOCK.
**Right:** Actively attempt UNBLOCK on regular schedule.

### ❌ Anti-pattern: Blocking Without Documentation
**Wrong:** "It's blocked" without specific conditions.
**Right:** Clear blocker description and unblocking conditions via BLOCK command.

### ❌ Anti-pattern: Premature Blocking
**Wrong:** Marking task blocked without exploring alternatives first.
**Right:** Explore workarounds, only block if truly stuck.

### ❌ Anti-pattern: Over-Blocking
**Wrong:** Blocking entire task when only part is blocked.
**Right:** Complete unblocked portions, block specific subtask only.

### ❌ Anti-pattern: Forgetting Blocked Tasks
**Wrong:** Selecting new work and forgetting to retry UNBLOCK.
**Right:** Set regular schedule to attempt UNBLOCK on all blocked tasks.

---

## 🔀 WORKFLOW VARIATIONS

### Partial Unblocking
If blocker is partially resolved:
1. UNBLOCK documents what can now proceed
2. Break task into unblocked and still-blocked portions
3. Complete unblocked portion with START
4. Keep blocked portion marked BLOCKED
5. Retry UNBLOCK later for remaining portion

### Blocker Resolved by Others
If external party resolves blocker:
1. UNBLOCK verifies resolution
2. Documents who/how it was resolved
3. Resumes work immediately
4. Captures timeline and process for future reference

### Blocker Becomes Permanent
If blocker will never be resolved:
1. UNBLOCK documents that blocker is permanent
2. Reassess task viability with PRD
3. Use [ARCHIVE](../COMMANDS/ARCHIVE.md) with explanation
4. Remove from TODO or mark as deferred
5. Document lessons learned

---

## 🔗 RELATED COMMANDS & WORKFLOWS
- [UNBLOCK](../COMMANDS/UNBLOCK.md) - Core command for attempting resolution
- [BLOCK](../COMMANDS/BLOCK.md) - How tasks become blocked (used within other workflows)
- [FEATURE_CYCLE](./FEATURE_CYCLE.md) - Resume this after successful unblocking
- [BUG_CYCLE](./BUG_CYCLE.md) - Resume this if bug fix was blocked
- [SELECT_NEXT](../COMMANDS/SELECT_NEXT.md) - Find alternative work if still blocked

---

## 📝 EXAMPLE EXECUTIONS

### Example 1: Successfully Unblocked

```
Prerequisite: Task "B1.3 Test Markdown output" previously blocked
→ Blocker: Missing Symbol test fixtures
→ Unblocking condition: Symbol fixtures created in Fixtures/

1. UNBLOCK attempts resolution
   → Check if fixtures now exist
   → Found: Fixtures were added by teammate yesterday
   → Verify fixtures are usable
   → Result: ✅ Unblocked

2. Resume Work
   → Update TODO (remove BLOCKED status)
   → Update INPROGRESS (document resolution)
   → Continue with START command
   → Complete implementation
   → ARCHIVE when done
```

### Example 2: Still Blocked - Pivot

```
Prerequisite: Task "C2.1 Integrate DocC API" previously blocked
→ Blocker: Awaiting DocC 2.0 release with Swift 6 support
→ Unblocking condition: DocC 2.0 publicly available

1. UNBLOCK attempts resolution
   → Check DocC releases page
   → Latest version: Still 1.9.2
   → Contact DocC team: ETA 2 more weeks
   → Result: ❌ Still blocked

2. Pivot to Alternative Work
   → Document retry schedule: Check weekly
   → SELECT_NEXT identifies "C1.2 CLI argument parsing"
   → Execute FEATURE_CYCLE on C1.2
   → Set reminder to retry UNBLOCK next week

3. Next Week: Retry UNBLOCK
   → Check DocC releases: Now 2.0 available!
   → Mark C2.1 unblocked
   → Resume work with START
```

### Example 3: Partial Unblocking

```
Prerequisite: Task "D1 Add CI pipeline" partially blocked
→ Blocker: Need GitHub Actions runner access

1. UNBLOCK discovers workaround
   → GitHub Actions still pending
   → Can use local CI scripts as interim solution
   → Result: ⚠️ Partially unblocked

2. Split Task
   → Break into: "Local CI scripts" (unblocked) + "GitHub Actions" (blocked)
   → Complete local scripts with START
   → Keep GitHub Actions portion marked BLOCKED
   → Retry UNBLOCK periodically for GitHub Actions

3. Later: Full Unblocking
   → UNBLOCK: GitHub Actions access granted
   → Complete GitHub Actions integration
   → ARCHIVE entire task
```

**Result:** Productive work continues whether blocker is resolved or not; blocked tasks are actively managed.
