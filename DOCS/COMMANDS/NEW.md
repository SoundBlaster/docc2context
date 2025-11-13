# SYSTEM PROMPT: Capture New docc2context Requirement

## 🧩 PURPOSE
Translate fresh ideas, feature requests, or research spikes into the planning system so they fit alongside existing PRD scope.

---

## 🎯 GOAL
When a new requirement emerges:
- articulate the motivation and DocC-specific impact,
- determine where it belongs within Phases A–D or if it is a post-MVP consideration,
- update the PRD/workplan/TODO artifacts so the request can be prioritized and executed.

---

## 🔗 REFERENCE MATERIALS
- [PRD](../PRD/docc2context_prd.md) for existing scope boundaries.
- [Workplan](../workplan.md) to place the work in the proper phase.
- [TODO list](../todo.md) to add actionable entries once the idea is refined.
- Archive summary for analogous tasks that can serve as patterns.

---

## ⚙️ EXECUTION STEPS
1. **Describe the Idea**
   - Provide a short title, problem statement, and desired outcome.
   - Note whether it affects CLI UX, parsing, Markdown emission, determinism, or packaging.
2. **Classify the Work**
   - Map to PRD section: Phase A (infra), B (CLI contract), C (conversion pipeline), D (quality gates).
   - Identify dependencies or prerequisites (tests, fixtures, tokens, etc.).
3. **Assess Impact & Priority**
   - Does this unblock current work? Improve determinism? Expand reach?
   - Assign provisional priority (P0 critical, P1 important, P2 stretch) with rationale.
4. **Propose Validation Strategy**
   - Outline how to prove success (new XCTest cases, snapshot fixtures, CLI demo, README change).
5. **Update Docs**
   - Append a new entry under the appropriate PRD table row or add a subsection describing the feature.
   - Update `DOCS/workplan.md` if the sequencing or dependencies change.
   - Add a checkbox entry to `DOCS/todo.md` under the relevant heading, referencing the new PRD text.
6. **Communicate Availability**
   - Mention the new item during the next STATE update or link it in the README if public visibility matters.

---

## ✅ EXPECTED OUTPUT
- PRD and workplan entries reflecting the new requirement.
- TODO checkbox ready for [SELECT_NEXT](./SELECT_NEXT.md) to consider.
- Any supporting context captured in `DOCS/INPROGRESS/` if immediate research began.
