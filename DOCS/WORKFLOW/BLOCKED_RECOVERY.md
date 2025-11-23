# SYSTEM PROMPT: Blocked Task Recovery Workflow

## 🔄 WORKFLOW OVERVIEW
Handle tasks that become blocked by dependencies, missing resources, or external factors. This workflow ensures blocked work is properly documented, alternatives are explored, blockers are actively resolved, and work can resume efficiently once unblocked.

## 🎯 GOAL
Successfully navigate task blockers by:
1. Identifying and documenting the specific blocker
2. Defining clear unblocking conditions
3. Exploring workarounds or alternative approaches
4. Either resolving the blocker or pivoting to productive work
5. Resuming blocked task once conditions are met

This workflow prevents stalled work from being forgotten and ensures team visibility into dependencies.

---

## 🔗 REFERENCE MATERIALS
- [BLOCK Command](../COMMANDS/BLOCK.md) for blocker documentation format
- [SELECT_NEXT Command](../COMMANDS/SELECT_NEXT.md) for alternative task selection
- [TODO](../todo.md) for task dependencies and priorities
- [Workplan](../workplan.md) for phase dependencies
- [PRD](../PRD/docc2context_prd.md) for requirements context

---

## 📋 ORCHESTRATION STEPS

### Step 1: Blocker Identification & Documentation
**Command:** [BLOCK](../COMMANDS/BLOCK.md)

**Actions:**
1. **Blocker Analysis:**
   - Identify specific blocker (dependency, resource, external factor)
   - Determine if blocker is temporary or requires active resolution
   - Assess if partial progress can be made
   - Check if blocker affects other tasks

2. **Documentation:**
   - Create/update `DOCS/INPROGRESS/[TaskID]_[TaskName].md`
   - Add BLOCKED section with:
     - Specific blocker description
     - Why this blocks progress
     - Clear unblocking conditions
     - Expected timeline if known
     - Who/what needs to act

3. **Impact Assessment:**
   - List affected tasks and features
   - Identify if blocker cascades to other work
   - Determine urgency of resolution
   - Note workarounds if any exist

4. **Tracking Updates:**
   - Mark task as BLOCKED in `DOCS/todo.md`
   - Update workplan if phase timing affected
   - Note blocker in any INPROGRESS docs
   - Communicate to team if critical

**Validation:**
- Blocker is clearly documented
- Unblocking conditions are specific and measurable
- Impact on timeline is assessed
- TODO reflects blocked status

**Output:** Blocker documented with clear resolution criteria.

---

### Step 2: Resolution Strategy

**Decision Point:** Can you resolve the blocker yourself?

#### Path A: Self-Resolvable Blocker

**Examples:**
- Missing test fixtures (can create them)
- Unclear requirements (can research in PRD/code)
- Dependency on own prior work (can complete it)
- Technical design decision (can prototype options)

**Actions:**
1. **Plan Resolution:**
   - Define what needs to be done to unblock
   - Estimate effort required
   - Check if resolution is higher priority than other TODO items

2. **Execute Resolution:**
   - Create TODO entries for resolution steps
   - Follow [FEATURE_CYCLE](./FEATURE_CYCLE.md) or appropriate workflow
   - Complete resolution work
   - Verify unblocking conditions are met

3. **Resume Original Task:**
   - Update INPROGRESS doc (blocker resolved)
   - Mark task as unblocked in TODO
   - Continue with original work
   - Document resolution approach

**Output:** Blocker self-resolved, original work resumes.

---

#### Path B: External Blocker (Cannot Self-Resolve)

**Examples:**
- Waiting for external API access
- Blocked by teammate's work
- Awaiting design/product decisions
- Dependency on third-party library update
- Infrastructure/tooling issues

**Actions:**
1. **Escalation/Communication:**
   - Document who needs to act
   - Provide them with context and requirements
   - Set clear unblocking conditions
   - Agree on expected timeline if possible

2. **Explore Workarounds:**
   - Can task be partially completed?
   - Can you mock/stub the dependency temporarily?
   - Is there an alternative approach?
   - Can scope be adjusted to avoid blocker?

3. **Pivot to Alternative Work:**
   - Use [SELECT_NEXT](../COMMANDS/SELECT_NEXT.md) to find unblocked task
   - Prioritize work that doesn't share the same blocker
   - Update workplan if phase sequencing changes
   - Set reminder to check blocker status

4. **Periodic Re-evaluation:**
   - Check blocker status regularly (daily for critical, weekly for normal)
   - Update INPROGRESS doc with status changes
   - Resume work once unblocked
   - Document timeline and learnings

**Output:** Alternative productive work identified, blocked task tracked for resumption.

---

### Step 3: Resumption After Unblocking

**Trigger:** Unblocking conditions are met

**Actions:**
1. **Verify Unblocking:**
   - Confirm blocker is fully resolved
   - Test that work can actually proceed
   - Check for any new blockers that emerged
   - Update INPROGRESS doc with resolution

2. **Re-planning:**
   - Review original task plan in INPROGRESS
   - Check if approach needs adjustment based on resolution
   - Verify prerequisites are still valid
   - Update TODO if priorities shifted

3. **Resume Work:**
   - Mark task as in-progress (not blocked) in TODO
   - Continue implementation following [START](../COMMANDS/START.md)
   - Reference blocker resolution in commit messages if relevant
   - Document any changes from original plan

4. **Post-Resolution Documentation:**
   - Update INPROGRESS with how blocker was resolved
   - Note timeline from blocked to unblocked
   - Record lessons for preventing similar blockers
   - Update workplan if timing changed

**Output:** Work successfully resumed and completed.

---

## ✅ EXPECTED OUTPUT

After completing this workflow, you should have:

### Documentation Artifacts:
- ✅ Blocker clearly documented in INPROGRESS
- ✅ Unblocking conditions specified
- ✅ Resolution approach recorded
- ✅ Timeline impact documented
- ✅ TODO reflects current status (blocked → unblocked → complete)

### Workflow Outcomes:
- ✅ Either blocker resolved or alternative work identified
- ✅ No time wasted waiting without documentation
- ✅ Team visibility into dependencies
- ✅ Lessons learned for preventing similar blockers

### Knowledge Captured:
- ✅ What caused the blocker
- ✅ How it was resolved (or who resolved it)
- ✅ How long resolution took
- ✅ Prevention strategies for future

---

## 🚨 COMMON PITFALLS

### ❌ Anti-pattern: Silent Blocking
**Wrong:** Hitting a blocker and just stopping work without documentation.
**Right:** Document blocker immediately with BLOCK command.

### ❌ Anti-pattern: Waiting Passively
**Wrong:** Documenting blocker and doing nothing while waiting.
**Right:** Explore workarounds and pivot to alternative work.

### ❌ Anti-pattern: Vague Blockers
**Wrong:** "Blocked on infrastructure" without specifics.
**Right:** "Blocked on Swift 6.0.3 installation - requires sudo access to /usr/local"

### ❌ Anti-pattern: Over-Blocking
**Wrong:** Marking entire task blocked when only one subtask is blocked.
**Right:** Break task down; complete unblocked portions, block specific subtask.

### ❌ Anti-pattern: Forgetting Blocked Work
**Wrong:** Moving to new work and never checking blocked task again.
**Right:** Set regular reminders to re-evaluate blocker status.

---

## 🔀 WORKFLOW VARIATIONS

### Partial Blocking
If only part of task is blocked:
1. Document which specific portion is blocked
2. Continue work on unblocked portions
3. Use mocks/stubs if appropriate
4. Complete unblocked work
5. Return to blocked portion when unblocked

### Multiple Blockers
If task has multiple blockers:
1. Document all blockers separately
2. Prioritize which blockers to resolve first
3. Resolve self-resolvable blockers immediately
4. Track external blockers independently
5. Resume when ALL blockers are cleared

### Blocker Becomes Permanent
If blocker won't be resolved:
1. Reassess task viability
2. Update PRD if requirements changed
3. Archive task with explanation
4. Remove from TODO or mark as deferred
5. Document lessons learned

---

## 🔗 RELATED WORKFLOWS
- [FEATURE_CYCLE](./FEATURE_CYCLE.md) - Resume this workflow after unblocking
- [BUG_CYCLE](./BUG_CYCLE.md) - If blocker is caused by a bug
- Use [STATE](../COMMANDS/STATE.md) to communicate blocker status during handoffs
- Use [NEW](../COMMANDS/NEW.md) if blocker reveals new requirements

---

## 📝 EXAMPLE EXECUTIONS

### Example 1: Self-Resolvable Blocker

```
1. BLOCK identifies missing test fixtures
   → Task "B1.3 Test Markdown output" blocked
   → Blocker: No Symbol test fixtures exist
   → Unblocking: Create Symbol fixtures in Fixtures/

2. Resolution Strategy: Self-resolvable
   → Add TODO: "Create Symbol test fixtures"
   → Run FEATURE_CYCLE to create fixtures
   → Verify fixtures work correctly

3. Resumption
   → Mark "B1.3 Test Markdown output" unblocked
   → Continue with original Markdown testing task
   → Complete using START command
```

### Example 2: External Blocker with Pivot

```
1. BLOCK identifies external dependency
   → Task "C2.1 Integrate DocC API" blocked
   → Blocker: Waiting for DocC team to publish Swift 6 compatible API
   → Unblocking: DocC 2.0 release (ETA: 2 weeks)

2. Resolution Strategy: External blocker
   → Document blocker with DocC team
   → No workaround available (core API needed)
   → Run SELECT_NEXT to find alternative work

3. Pivot to Alternative Work
   → SELECT_NEXT identifies "C1.2 CLI argument parsing"
   → Complete C1.2 using FEATURE_CYCLE
   → Set weekly reminder to check DocC 2.0 status

4. Resumption (2 weeks later)
   → DocC 2.0 released
   → Verify API is available
   → Mark C2.1 unblocked in TODO
   → Resume integration work with START
```

**Result:** Productive work continued during blocking period, original task resumed when unblocked.
