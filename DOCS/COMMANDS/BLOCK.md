# SYSTEM PROMPT: Mark docc2context Task as Blocked

## 🧩 PURPOSE
Document tasks that cannot proceed due to blockers (dependencies on other tasks, missing resources, external decisions, or environmental issues) while maintaining traceability and enabling systematic unblocking.

---

## 🎯 GOAL
Every blocked task entry should:
- clearly identify what is preventing progress (specific task dependencies, missing artifacts, pending decisions),
- point to blocking tasks/issues with PRD references or external links,
- record when the block was identified and by whom,
- establish unblocking conditions (what must happen to resume work),
- update TODO and INPROGRESS documentation to reflect blocked status.

---

## 🔗 REFERENCE MATERIALS
- [PRD](../PRD/docc2context_prd.md) — verify task dependencies and acceptance criteria.
- [Workplan](../workplan.md) — understand phase sequencing and prerequisites.
- [TODO list](../todo.md) — mark tasks as blocked and add unblocking conditions.
- [`DOCS/INPROGRESS/`](../INPROGRESS) — update active task notes with blocker details.
- [Phase Checklist Index](../PRD/phases.md) — identify upstream dependencies.

---

## 📋 BLOCKER CATEGORIES

### 1. Task Dependencies
Task cannot start or continue until another task completes.
- **Example**: "B2.3 blocked by B1.1 — need baseline Symbol parser before snapshot tests"
- **Resolution**: Complete blocking task, verify deliverables, then unblock

### 2. Technical Blockers
Missing infrastructure, tooling, or environmental issues.
- **Example**: "C1.2 blocked — Swift 6.0.3 not available in CI environment"
- **Resolution**: Set up required environment/tooling per [SWIFT_SETUP.md](../RULES/SWIFT_SETUP.md)

### 3. External Dependencies
Waiting on external decisions, third-party APIs, or outside resources.
- **Example**: "D3.1 blocked — awaiting design decision on output format from stakeholder"
- **Resolution**: Document decision request, track externally, mark unblock date

### 4. Knowledge Gaps
Insufficient understanding to proceed safely without research.
- **Example**: "A3.2 blocked — need to investigate DocC JSON schema versioning before parsing"
- **Resolution**: Create research spike task, document findings, then unblock

### 5. Resource Constraints
Lack of fixtures, test data, or reference materials.
- **Example**: "B1.4 blocked — missing representative .doccarchive samples for edge cases"
- **Resolution**: Generate/acquire resources, validate, then unblock

---

## ⚙️ EXECUTION STEPS

### 1. Identify and Document the Blocker
   - Determine blocker category (task dependency, technical, external, knowledge, resource)
   - Record specific details:
     - What task is blocked (PRD ID: A1, B2.3, etc.)
     - What is blocking it (task ID, issue, missing resource)
     - When the block was identified (date)
     - Impact on workplan timeline
   - Capture evidence (error logs, missing fixtures, unanswered questions)

### 2. Update TODO List
   - Mark the blocked task clearly in `DOCS/todo.md`:
     ```markdown
     - [ ] **B2.3** Snapshot testing for Symbols — ⛔ BLOCKED by B1.1
       - Blocker: Need baseline Symbol parser implementation
       - Unblock condition: B1.1 complete with passing tests
       - Blocked since: 2025-01-15
     ```
   - Add priority flag if block is critical path

### 3. Update INPROGRESS Note
   - If task has an active INPROGRESS file, add blocker section:
     ```markdown
     ## ⛔ BLOCKER
     **Status**: BLOCKED as of YYYY-MM-DD
     **Blocked by**: [Task ID or description]
     **Category**: [Task Dependency / Technical / External / Knowledge / Resource]
     **Details**: [Explanation of what's blocking and why]
     **Unblock Conditions**:
     - [ ] Condition 1
     - [ ] Condition 2
     **Workarounds Considered**: [Any alternative approaches evaluated and why rejected]
     ```
   - Move INPROGRESS note to a `BLOCKED_` prefix if actively halted

### 4. Create Unblocking Plan
   - For task dependencies:
     - Verify blocking task is in TODO/INPROGRESS
     - Adjust workplan sequencing if needed
     - Consider if blocked task can be split (unblocked portions vs blocked portions)
   - For technical blockers:
     - Document required setup steps
     - Create prerequisite task if significant work required
     - Link to setup guides ([SWIFT_SETUP.md](../RULES/SWIFT_SETUP.md), etc.)
   - For external dependencies:
     - Document what was requested and from whom
     - Set follow-up date to check status
     - Identify interim workarounds if available
   - For knowledge gaps:
     - Create research/spike task in TODO
     - Define scope and success criteria for research
     - Set time-box for investigation
   - For resource constraints:
     - Document what's needed and where to obtain it
     - Create task to generate/acquire resources
     - Identify temporary alternatives if available

### 5. Communicate Block Status
   - If blocker affects critical path or multiple tasks:
     - Note in next [STATE](./STATE.md) report
     - Update workplan risk section
     - Alert stakeholders if external action needed
   - Document blocker in relevant phase checklist if it impacts phase completion

### 6. Schedule Blocker Review
   - Add blocker review to next planning session
   - Set reminder to check external dependencies
   - Monitor blocking tasks for completion

---

## 🔓 UNBLOCKING WORKFLOW

When conditions change and task can resume:

1. **Verify Unblock Conditions Met**
   - Check all unblock conditions are satisfied
   - Validate deliverables from blocking tasks
   - Confirm resources/decisions are available

2. **Update Documentation**
   - Remove ⛔ BLOCKED flag from `DOCS/todo.md`
   - Add UNBLOCKED note with date to INPROGRESS file
   - Document what changed to enable unblocking

3. **Resume Work**
   - Run [SELECT_NEXT](./SELECT_NEXT.md) to reprioritize if needed
   - Run [START](./START.md) to resume implementation
   - Reference blocker history in task notes for context

---

## ✅ EXPECTED OUTPUT
- Clear documentation of what's blocked and why
- Updated TODO entries with blocker flags and unblock conditions
- INPROGRESS notes with blocker details and resolution plans
- Unblocking plan with concrete next steps
- Workplan updates if block affects phase sequencing
- State report entry if block is critical

---

## 📊 BLOCKER TRACKING

Maintain blocker visibility:
- Mark blocked tasks clearly in TODO with ⛔ emoji or **BLOCKED** label
- Track blocker age (days since blocked) in status reports
- Review all blocked tasks weekly to check for unblock opportunities
- Escalate long-running blockers (>1 week) in STATE reports

---

## 🔄 RELATED COMMANDS
- [STATE](./STATE.md) — include blocker summary in status reports
- [SELECT_NEXT](./SELECT_NEXT.md) — automatically skip blocked tasks when selecting next work
- [START](./START.md) — resume work after unblocking
- [NEW](./NEW.md) — create new tasks to resolve blockers
- [BUG](./BUG.md) — if blocker reveals a defect requiring fix
