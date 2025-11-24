# SYSTEM PROMPT: Attempt to Unblock docc2context Task

## 🧩 PURPOSE
Attempt to resolve blockers for a previously blocked task and determine if work can resume or if alternative action is needed.

---

## 🎯 GOAL
When a task has been marked as BLOCKED:
- Assess current status of the blocker
- Attempt resolution if possible
- Determine if task can now proceed
- If still blocked, identify next steps (wait, pivot, or escalate)

---

## 🔗 REFERENCE MATERIALS
- Existing `DOCS/INPROGRESS/[TaskID]_[TaskName].md` with BLOCKED section
- [TODO list](../todo.md) showing blocked task status
- [Workplan](../workplan.md) for dependency context
- [BLOCK command](./BLOCK.md) that originally marked the task

---

## ⚙️ EXECUTION STEPS

### 1. Review Blocker Documentation
- Read the BLOCKED section in the task's INPROGRESS document
- Identify the specific blocker that was documented
- Review the unblocking conditions that were defined
- Check when the task was originally blocked

### 2. Assess Current Blocker Status
- **For dependency blockers:** Check if the dependency is now available
- **For resource blockers:** Verify if resources are now accessible
- **For external blockers:** Confirm if external party has acted
- **For decision blockers:** Check if decisions have been made
- **For technical blockers:** Test if technical issues are resolved

### 3. Attempt Unblocking

**If blocker is resolved:**
- Document how/when it was resolved
- Update INPROGRESS document (remove BLOCKED status)
- Mark task as unblocked in `DOCS/todo.md`
- Verify all prerequisites are now satisfied
- **Next step:** Resume work with [START](./START.md) command or continue [FEATURE_CYCLE](../WORKFLOW/FEATURE_CYCLE.md)

**If blocker is partially resolved:**
- Document what changed
- Assess if partial progress is now possible
- Consider breaking task into unblocked and still-blocked portions
- Update INPROGRESS with current status
- **Next step:** Either START on unblocked portion or continue waiting

**If blocker remains:**
- Document that blocker was checked but still exists
- Update expected resolution timeline if changed
- Confirm unblocking conditions are still accurate
- **Next step:** Use [SELECT_NEXT](./SELECT_NEXT.md) to pivot to alternative work

---

## ✅ EXPECTED OUTPUT

### When Successfully Unblocked:
- INPROGRESS document updated (BLOCKED section removed or marked resolved)
- `DOCS/todo.md` shows task as no longer blocked
- Clear path to resume implementation
- Documentation of how blocker was resolved

### When Still Blocked:
- INPROGRESS document updated with latest blocker status
- Updated timeline or conditions if changed
- Clear next action (wait, escalate, or pivot)
- Decision to work on alternative task

### When Partially Unblocked:
- Documentation of what can now proceed
- Clear separation of unblocked vs still-blocked work
- Plan for addressing each portion

---

## 🔄 COMMON SCENARIOS

### Scenario 1: Dependency Now Available
```
Original blocker: Waiting for SymbolParser module
UNBLOCK check: SymbolParser merged to main
Result: ✅ Unblocked
Action: Resume with START command
```

### Scenario 2: Still Waiting
```
Original blocker: Awaiting API keys from external service
UNBLOCK check: No response yet from service provider
Result: ❌ Still blocked
Action: SELECT_NEXT to find alternative work
```

### Scenario 3: Workaround Discovered
```
Original blocker: Missing production data
UNBLOCK check: Found we can use anonymized sample data
Result: ✅ Can proceed with modification
Action: Update approach, resume with START
```

---

## 🔗 RELATED COMMANDS
- [BLOCK](./BLOCK.md) - Original command that marked task as blocked
- [START](./START.md) - Resume implementation after unblocking
- [SELECT_NEXT](./SELECT_NEXT.md) - Choose alternative work if still blocked
- [FEATURE_CYCLE](../WORKFLOW/FEATURE_CYCLE.md) - Complete workflow including resumption

---

## 📝 NOTES
- UNBLOCK should be attempted periodically for blocked tasks (daily for critical, weekly for normal)
- Don't wait passively - actively attempt to resolve blockers or find workarounds
- Document all unblocking attempts, even unsuccessful ones
- If blocker becomes permanent, consider archiving the task with explanation
