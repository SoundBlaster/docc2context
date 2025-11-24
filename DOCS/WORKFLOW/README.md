# docc2context Workflow Suite

The `DOCS/WORKFLOW` directory contains end-to-end workflow orchestrations that combine multiple [COMMANDS](../COMMANDS/README.md) into coherent, repeatable processes. While individual commands handle specific atomic tasks, workflows guide you through complete development cycles from start to finish.

## 🔄 Workflows vs Commands

| Type | Scope | Purpose | Example |
| --- | --- | --- | --- |
| **Command** | Single atomic operation | Execute one specific task (select, start, archive, etc.) | [START](../COMMANDS/START.md) - Implement a single task |
| **Workflow** | Multi-step orchestration | Complete end-to-end process combining multiple commands | FEATURE_CYCLE - Full feature development from selection to archival |

## 📋 Available Workflows

| Workflow | Description | Commands Orchestrated |
| --- | --- | --- |
| [FEATURE_CYCLE](./FEATURE_CYCLE.md) | Complete feature development lifecycle: planning → implementation → delivery | SELECT_NEXT → START → ARCHIVE |
| [BUG_CYCLE](./BUG_CYCLE.md) | Bug discovery and resolution process | BUG → FIX → START → ARCHIVE |
| [BLOCKED_RECOVERY](./BLOCKED_RECOVERY.md) | Attempt to unblock and resume previously blocked tasks | UNBLOCK → (if successful) FEATURE_CYCLE/START or (if not) SELECT_NEXT |

## 🎯 When to Use Workflows

Use workflows when you need to:
- Execute a complete development cycle from scratch
- Ensure consistency across multi-step processes
- Onboard new team members with repeatable patterns
- Maintain discipline through complex task sequences
- Reduce cognitive load by following established patterns

Use individual [COMMANDS](../COMMANDS/README.md) when you:
- Know exactly which atomic operation to perform
- Are already mid-workflow and need a specific step
- Want fine-grained control over each operation

## 🧩 Workflow Structure

Each workflow document follows this template:

```markdown
# SYSTEM PROMPT: [Workflow Name]

## 🔄 WORKFLOW OVERVIEW
High-level description of the complete process.

## 🎯 GOAL
What successful completion of this workflow achieves.

## 📋 ORCHESTRATION STEPS
Step-by-step guide through the entire process, referencing specific commands.

## ✅ EXPECTED OUTPUT
What artifacts and states should exist after completion.

## 🔗 RELATED WORKFLOWS
Links to related or follow-up workflows.
```

## 🚀 Getting Started

1. **Read the workflow document** to understand the full process
2. **Verify prerequisites** mentioned in the workflow
3. **Follow orchestration steps** sequentially
4. **Validate outputs** match expected results
5. **Update tracking documents** as specified

## 🔗 Integration with Project Documentation

Workflows reference the same canonical sources as commands:
- [PRD](../PRD/docc2context_prd.md) for requirements and acceptance criteria
- [Workplan](../workplan.md) for phase sequencing and dependencies
- [TODO](../todo.md) for task queue and priorities
- [INPROGRESS](../INPROGRESS/) for active work tracking
- [TASK_ARCHIVE](../TASK_ARCHIVE/) for completed work history

---

**Use workflows when orchestrating multi-step processes. Use commands for atomic operations.**
