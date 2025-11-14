# A4 – Define Deployment & Release Gates

## Objective
Establish a documented release checklist and supporting automation so every publish/build run revalidates the `docc2context` pipeline before artifacts are tagged. Scope includes determinism hashing, fixture integrity checks, and enforcement that `swift test` + lint routines exit successfully, aligning with the PRD Phase A requirement for release gates.

## Reference Material
- `DOCS/PRD/docc2context_prd.md` — Phase A table entry **A4** plus acceptance criteria (release gate script enforces lint, determinism, and tests).
- `DOCS/workplan.md` — Phase A sequencing showing A4 can run in parallel with A3 after A1 is complete.
- `DOCS/TASK_ARCHIVE/` entries for A1/A2 that provide the current CI + TDD harness context.

## Dependencies & Assumptions
- [x] **A1 – SwiftPM + CI bootstrap**: gate script will extend the existing workflow.
- [x] **A2 – TDD harness utilities**: determinism + fixture checks will call into these helpers where possible.
- [ ] **A3 – Fixture population**: until bundles land, checksum/fixture validation will operate on placeholder manifest entries; script must tolerate missing archives but flag once fixtures exist.

## Deliverables
1. Markdown checklist covering mandatory steps before tagging a release (tests, determinism hash comparison, fixture verification, lint/format, artifact checksum capture).
2. Automation script(s) under `Scripts/` (likely Bash + Swift) that:
   - Run `swift test` and fail-fast on errors.
   - Invoke a determinism helper (double-run hash comparison or placeholder stub until Phase C/C5 implement data).
   - Recompute fixture checksums from `Fixtures/manifest.json` and compare to stored values.
   - Emit summarized status + exit non-zero when any gate fails.
3. Documentation update hooks (README/workflow notes) once the script exists (captured as follow-up once implementation begins via START command).

## Validation Plan
- Dry-run the script locally on Linux container to ensure all commands succeed with current repo state.
- Add (or extend) XCTest/SwiftPM tests for any Swift helper types introduced to support determinism hashing.
- Record shasum output for fixtures and compare against manifest as part of the script to ensure determinism gate is meaningful even before Markdown generation arrives.

## Open Questions / Risks
- Determinism verification currently lacks real conversion outputs; may need to introduce a placeholder double-run on fixtures directory hashing until conversion pipeline exists.
- Need to decide whether lint/formatting is enforced (e.g., `swift format` or `swiftlint`), or if the initial gate focuses on tests + determinism only.

## Immediate Next Actions
1. Inventory existing scripts/tooling to avoid duplication and sketch the release checklist outline (sections + required commands).
2. Decide on script language(s) and directory layout (e.g., `Scripts/release_gate.sh` plus helper Swift target) and capture that plan.
3. Identify any missing dependencies (e.g., need for `shasum` availability in CI) and add TODOs if prerequisites are unmet.
