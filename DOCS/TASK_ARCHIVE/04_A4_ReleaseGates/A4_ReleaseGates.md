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
- [x] Inventory existing scripts/tooling gaps and confirm directory layout for release gates.
- [x] Draft release gate checklist sections (tests, determinism hash, fixture verification, reporting).
- [x] Implement shell script scaffolding that runs `swift test` and placeholder determinism checks.
- [x] Define fixture manifest verification logic (stub until fixtures arrive).
- [x] Document how to invoke the gate script inside README/CI once functionality stabilizes.

## Current Progress Notes
- SELECT_NEXT identified A4 as the next Phase A priority. START session initiated to capture scope and begin execution.
- Created `Scripts/release_gates.sh` scaffold (initial run step) to serve as the automation entry point.

## Immediate Next Action
Inventory commands required for the release gate checklist, flesh out the script with TODO markers for each section, and add README/CI references once behavior is verified.

## Completion Summary – 2025-11-14
- Expanded `Scripts/release_gates.sh` so it now executes `swift test`, runs a deterministic CLI smoke command twice while comparing SHA-256 hashes, and calls a new `Scripts/validate_fixtures_manifest.py` helper.
- Authored `Scripts/validate_fixtures_manifest.py` to parse `Fixtures/manifest.json`, confirm bundle entries exist, match their checksums, and report the recorded byte sizes. When the manifest is still empty (pre-A3), the validator logs a warning instead of failing.
- Documented the release gate workflow in `README.md` and called out that the fixtures README + manifest schema now require `relative_path`, checksum, and size metadata for every bundle.

## Validation Evidence
- `swift test` (Linux) – executed directly and via `Scripts/release_gates.sh`.
- `Scripts/release_gates.sh` – runs the determinism hash comparison (`swift run docc2context --help` twice) and the fixture manifest validator. Current manifest is intentionally empty, so the validator emits a warning but exits 0.

## Follow-Ups
1. Task **A3** must populate `Fixtures/manifest.json` with real DocC bundles so the validator enforces checksum/size constraints instead of warning.
2. Once Markdown conversion exists, update `DETERMINISM_COMMAND` in CI to hash actual conversion outputs rather than the CLI help text.
