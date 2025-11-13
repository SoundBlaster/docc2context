# SYSTEM PROMPT: Fix docc2context Bug

## 🧩 PURPOSE
Drive a defect from reproduction to verified resolution while keeping planning docs and tests in sync.

---

## 🎯 GOAL
- Recreate the bug deterministically using documented steps.
- Add or update tests so the failure is captured before code changes.
- Implement the fix with minimal scope creep.
- Update docs (README, PRD, TODO, archive) to reflect the remediation.

---

## 🔗 REFERENCE MATERIALS
- Bug note created via [BUG](./BUG.md) (repro steps, severity, logs).
- [PRD](../PRD/docc2context_prd.md) section describing the broken requirement.
- [TODO list](../todo.md) entry tracking the fix.
- Existing tests/fixtures under `Tests/` or `Fixtures/` referenced by the bug.

---

## ⚙️ EXECUTION STEPS
1. **Restate the Problem**
   - Copy repro steps into a new `DOCS/INPROGRESS/FIX_{bugSlug}.md` note.
   - Clarify environment requirements and impacted code paths.
2. **Add Guarding Tests**
   - If missing, create failing XCTest or snapshot cases representing the defect.
   - Commit the failing test before implementation when feasible.
3. **Implement the Fix**
   - Modify the minimal surface area (CLI parsing, metadata loading, Markdown writer, etc.).
   - Re-run `swift test` plus determinism/fixture scripts.
4. **Validate Across Inputs**
   - Re-run conversions using fixtures mentioned in the bug report and any high-risk bundles.
   - Capture logs and hash comparisons if determinism was at risk.
5. **Update Documentation**
   - Mark the TODO checkbox as complete and note the fix in README or PRD if behavior changed.
   - Append archive entry with test references.
6. **Close the Loop**
   - Move the FIX note into `DOCS/TASK_ARCHIVE/` via [ARCHIVE](./ARCHIVE.md).
   - Mention the resolved bug in the next [STATE](./STATE.md) update.

---

## ✅ EXPECTED OUTPUT
- Passing tests demonstrating the fix.
- Updated docs describing the corrected behavior.
- Archived FIX note for future reference.
