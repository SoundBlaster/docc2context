# S2 – Align Docs/PRD with Archive Input Behavior

**Status:** Planning (SELECT_NEXT)
**Date:** 2025-12-18
**Owner:** docc2context agent
**Depends On:** None (documentation-only)

---

## 🎯 Intent

Reconcile documentation and PRD/workplan tracking around “archive inputs” (B4) with the current, tested CLI behavior:

- A `.doccarchive` **directory** is supported as an input bundle.
- A `.doccarchive` **file** is rejected with guidance to extract it before converting (see `Docc2contextCLITests.testArchiveInputProvidesExtractionGuidance`).

Several docs currently claim `ArchiveExtractor` exists and that `.doccarchive` file inputs are automatically extracted, but the codebase contract is the opposite.

---

## ✅ Selection Rationale

- **Doc sync:** The PRD and workplan still claim B4 “Extract Archive Inputs” is implemented automatically; that contradicts the CLI contract tests.
- **Operator clarity:** Users reading the PRD/workplan may expect `.doccarchive` files to “just work”, but the CLI intentionally requires manual extraction.
- **Maintenance:** This is a focused documentation clean-up that keeps historical context while making current behavior explicit.

---

## ✅ Scope (for START)

1. **Update PRD + Phase B docs**
   - Adjust `DOCS/PRD/docc2context_prd.md` and `DOCS/PRD/phase_b.md` wording for B4 to reflect “reject archive files with guidance” (or explicitly define “archive” as a directory, not a zip).
2. **Update workplan references**
   - Update `DOCS/workplan.md` B4 description to match current behavior.
3. **Annotate historical archive notes (don’t rewrite history)**
   - Add an addendum to `DOCS/TASK_ARCHIVE/10_B4_ArchiveExtraction/B4_ArchiveExtraction.md` clarifying that the current implementation no longer auto-extracts `.doccarchive` files, and pointing to the CLI tests that define the contract.
4. **Optional follow-up split (separate task if needed)**
   - Decide what to do with `Tests/Docc2contextCoreTests/ArchiveExtractionTests.swift` placeholder skips (delete, replace with “extraction guidance” tests, or keep as explicit “future extraction” placeholders).

---

## ✅ Success Criteria

- Documentation consistently describes the current behavior for `.doccarchive` inputs (directory vs file).
- PRD/workplan checklists do not claim an `ArchiveExtractor` implementation that does not exist in the repository.
- The CLI behavior remains unchanged (this is docs-only unless explicitly expanded into a follow-up implementation task).

---

## 📎 References

- `Tests/Docc2contextCoreTests/Docc2contextCLITests.swift` (archive file guidance test)
- `Sources/Docc2contextCore/InputLocationDetector.swift` (`archiveInputRequiresExtraction`)
- `DOCS/TASK_ARCHIVE/10_B4_ArchiveExtraction/B4_ArchiveExtraction.md`
- `DOCS/PRD/docc2context_prd.md` (Phase B table row for B4)
- `DOCS/PRD/phase_b.md`
- `DOCS/workplan.md`

