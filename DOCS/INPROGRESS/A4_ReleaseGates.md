# A4 – Define Deployment & Release Gates

## Objective
Establish an enforceable release checklist plus automation so every publish/build run revalidates the `docc2context` pipeline before artifacts are tagged. Scope includes determinism hashing, fixture integrity checks, and enforcement that `swift test` + lint routines exit successfully, aligning with the PRD Phase A requirement for release gates.

## Relevant PRD Paragraphs
- `DOCS/PRD/docc2context_prd.md` — Phase A table entry **A4** describing deterministic release gating, fixture checksum verification, and mandatory CI test execution.
- `DOCS/PRD/phases.md` — Phase A checklist rows for A4 referencing determinism hash comparison and fixture manifest validation.

## Test Plan
- Run `swift test` locally (Linux container) and via the planned gate script.
- Add command(s) in the gate script to compute determinism hash by hashing the repository outputs twice and comparing results (placeholder until Markdown generation lands).
- Use fixture manifest checksums (A3 deliverable) to validate `Fixtures/` integrity; until real fixtures exist, the script logs a warning but succeeds.
- Verify the gate script exits non-zero when any subprocess fails (tested via deliberate failure injection once logic exists).

## Dependencies
- [x] **A1 – SwiftPM + CI bootstrap** (script will reuse existing package + CI structure).
- [x] **A2 – TDD harness utilities** (checksum helpers and fixture loaders live here once implemented).
- [ ] **A3 – Fixture population** (gate script must degrade gracefully until manifest entries exist).

## Blocking Questions
1. Should lint/format checks (e.g., `swift format`) run inside the same gate script or a separate CI job? Pending decision.
2. What deterministic artifact(s) should be hashed before conversion pipeline exists? Currently planning to hash fixture directories as placeholder.

## Sub-task Checklist
- [ ] Inventory existing scripts/tooling gaps and confirm directory layout for release gates.
- [ ] Draft release gate checklist sections (tests, determinism hash, fixture verification, reporting).
- [ ] Implement shell script scaffolding that runs `swift test` and placeholder determinism checks.
- [ ] Define fixture manifest verification logic (stub until fixtures arrive).
- [ ] Document how to invoke the gate script inside README/CI once functionality stabilizes.

## Current Progress Notes
- SELECT_NEXT identified A4 as the next Phase A priority. START session initiated to capture scope and begin execution.
- Created `Scripts/release_gates.sh` scaffold (initial run step) to serve as the automation entry point.

## Immediate Next Action
Inventory commands required for the release gate checklist, flesh out the script with TODO markers for each section, and add README/CI references once behavior is verified.
