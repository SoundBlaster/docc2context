# S1 – DOCS Tracking Hygiene (Post-H4/H5 Implementation)

**Status:** Planning (SELECT_NEXT)
**Date:** 2025-12-17
**Owner:** docc2context agent
**Depends On:** None (documentation-only)

---

## 🎯 Intent

Keep `DOCS/` tracking accurate by reconciling the “planning” notes still present in `DOCS/INPROGRESS/` with the fact that the corresponding implementation work has already been archived, and by deciding how to track/archive the Linux coverage gate investigation note.

This task is intentionally documentation-only: no Swift code, tests, fixtures, or workflows should be changed as part of S1.

---

## ✅ Selection Rationale
- **Queue health:** `DOCS/todo.md` currently has no “Ready to Start” items; the remaining “In Progress” entries are largely planning artifacts from pre-implementation stages.
- **Doc sync:** H4/H5 implementations are already archived, but their original planning notes remain listed as active work.
- **Operator clarity:** The Linux coverage gate issue is documented in `DOCS/INPROGRESS/coverage_gate_linux_low_coverage.md`; it should be either linked from TODO or moved to an archive location so INPROGRESS reflects current work.

---

## 📐 Scope for START
When START is invoked for S1, perform only the following documentation actions:

1. **Reconcile TODO vs archives**
   - Update `DOCS/todo.md` to reflect that H4/H5 planning is no longer active (their implementations are complete and archived).
   - Decide whether to keep H4/H5 planning notes as historical context (and move them to `DOCS/TASK_ARCHIVE/`) or to mark them completed with a pointer to the implementation archives.

2. **Archive/relocate stale planning notes**
   - Move `DOCS/INPROGRESS/H4_RepoValidationHarness.md` and `DOCS/INPROGRESS/H5_RepositoryMetadataFixtures.md` into an appropriate `DOCS/TASK_ARCHIVE/` folder (documentation-only archival), cross-linking to:
     - `DOCS/TASK_ARCHIVE/40_H4_RepositoryValidationHarnessImplementation/`
     - `DOCS/TASK_ARCHIVE/39_H5_RepositoryMetadataFixturesImplementation/`

3. **Resolve coverage-gate note placement**
   - Decide whether `DOCS/INPROGRESS/coverage_gate_linux_low_coverage.md` should be:
     - moved into `DOCS/TASK_ARCHIVE/` as a “maintenance/CI incident” note, or
     - explicitly tracked in `DOCS/todo.md` (if follow-up work remains).

4. **Update archive summary (if any files are moved)**
   - Append a short, documentation-only entry to `DOCS/TASK_ARCHIVE/ARCHIVE_SUMMARY.md` describing what was archived and why.

---

## 🔎 Current State Check
- **INPROGRESS planning notes**
  - `DOCS/INPROGRESS/H4_RepoValidationHarness.md` (planning; predates implementation archive)
  - `DOCS/INPROGRESS/H5_RepositoryMetadataFixtures.md` (planning; predates implementation archive)
  - `DOCS/INPROGRESS/coverage_gate_linux_low_coverage.md` (CI incident note; not tracked in TODO)
- **Implementation archives**
  - `DOCS/TASK_ARCHIVE/40_H4_RepositoryValidationHarnessImplementation/`
  - `DOCS/TASK_ARCHIVE/39_H5_RepositoryMetadataFixturesImplementation/`

---

## ✅ Success Criteria
- `DOCS/todo.md` reflects the true “active” work in `DOCS/INPROGRESS/`.
- Any moved notes are properly cross-linked and summarized in `DOCS/TASK_ARCHIVE/ARCHIVE_SUMMARY.md`.
- No functional code/tests/fixtures/workflows are changed as part of this task.

---

## 🧾 Execution Notes (START)
- **Docs-only exception:** S1 is a tracking hygiene task; implementation is limited to `DOCS/` updates and file moves.
- **Primary changes planned:**
  - Remove stale “planning” entries for H4/H5 from `DOCS/todo.md` (implementations already archived).
  - Move stale planning notes (`H4_RepoValidationHarness.md`, `H5_RepositoryMetadataFixtures.md`) out of `DOCS/INPROGRESS/`.
  - Move the Linux coverage gate incident note out of `DOCS/INPROGRESS/` (archive location), keeping the fix details discoverable.

---

## ✅ Completion Checklist
- [x] `DOCS/todo.md` updated (H4/H5 planning removed; S1 marked complete).
- [x] Stale notes moved from `DOCS/INPROGRESS/` to `DOCS/TASK_ARCHIVE/`.
- [x] `DOCS/TASK_ARCHIVE/ARCHIVE_SUMMARY.md` updated with an S1 entry.

---

## ✅ Completed (ARCHIVE)
- Updated `DOCS/todo.md` to remove stale planning entries for H4/H5 (implementations already archived).
- Moved stale notes out of `DOCS/INPROGRESS/` into `DOCS/TASK_ARCHIVE/45_S1_DocsTrackingHygiene/`:
  - `H4_RepoValidationHarness.md` → `H4_RepoValidationHarness_Planning.md`
  - `H5_RepositoryMetadataFixtures.md` → `H5_RepositoryMetadataFixtures_Planning.md`
  - `coverage_gate_linux_low_coverage.md` → `coverage_gate_linux_low_coverage.md`
  - `S1_DocsTrackingHygiene.md` → `S1_DocsTrackingHygiene.md`
- **Validation:** Documentation-only changes; no Swift code/tests/fixtures/workflows modified as part of S1.

## 📎 References
- [SELECT_NEXT](../../COMMANDS/SELECT_NEXT.md)
- [ARCHIVE](../../COMMANDS/ARCHIVE.md)
- `DOCS/todo.md`
- `DOCS/workplan.md`
- `DOCS/TASK_ARCHIVE/ARCHIVE_SUMMARY.md`
