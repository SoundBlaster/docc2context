# D2 – Harden Test Coverage (Cycle 4 Selection)

## Overview
Phase D requires a release-ready CLI with demonstrably high confidence in determinism and failure handling. Task D2 focuses on
raising coverage on the Markdown pipeline, determinism validator, and CLI seams to at least 90% before documentation and
packaging work start. This planning note captures the test inventory, data sources, and automation hooks needed ahead of
implementation.

## Objective
1. Audit current unit/integration coverage after C5 lands and identify gaps (failure-paths, large bundle edges, CLI flags).
2. Author failing tests for missing behaviors (e.g., double-run mismatch reporting, corrupted fixture fallbacks, log coverage).
3. Configure coverage tooling (SwiftPM + `llvm-cov`) inside release gates and CI to enforce >=90% line coverage on core targets.
4. Ensure local developer workflow mirrors CI coverage gates.

## PRD / Workplan References
- **PRD §Phase D, Task D2** – Harden Test Coverage (>90% critical-path coverage enforced by CI badge).
- **Workplan Phase D** – D2 precedes D3 README updates and D4 packaging.
- **TODO Entry** – `DOCS/todo.md` “In Progress” item added via `SELECT_NEXT` (2025-11-18).

## Dependencies & Preconditions
- ✅ Phases A–C complete (per `DOCS/workplan.md`).
- ⏳ **C5 Verify Determinism** must land so we can hook the coverage gates onto the finalized determinism workflow.
- ✅ Fixtures + snapshot specs already cover tutorials/articles; leverage them for new tests.

## Inputs & Research Notes
- Coverage data: `swift test --enable-code-coverage` output + `llvm-cov report`.
- Existing automation: `Scripts/release_gates.sh` (currently runs `swift test`, determinism smoke, fixture validation).
- CI context: `.github/workflows/ci.yml` needs coverage stage/perf thresholds.
- Potential helper packages: consider lightweight Swift script or Python helper to parse `.profdata` and enforce thresholds.

## Proposed Test Coverage Targets
| Area | Gap / Risk | Planned Tests |
| --- | --- | --- |
| Determinism validator (C5) | No failing-path coverage when hashes differ | Unit test forcing mismatched hashes to assert descriptive error + CLI exit code |
| MarkdownGenerationPipeline failure modes | Limited coverage for filesystem/IO errors | Inject failing file writers via test doubles to hit error branches |
| LinkGraph + TOC/index determinism | Need second-run diff coverage | Snapshot/hash comparison tests verifying JSON + Markdown ordering |
| CLI flags (`--format`, future filters) | Ensure unused args rejected deterministically | Additional CLI tests covering invalid filter combos + `--help` output |
| Release gates script | No automated test | Add shell-test harness or script unit test verifying coverage enforcement |

## Tooling & Automation Plan
1. **Coverage Measurement** – Use `swift test --enable-code-coverage` to produce `.profdata`. Add helper script (Swift or Python)
   that wraps `llvm-cov export` to compute per-target totals and enforce >=90% for `docc2context` + `Docc2contextCore` targets.
2. **CI Integration** – Extend `.github/workflows/ci.yml` with a `coverage` job triggered after determinism checks. Job should
   upload coverage summary (artifact + PR comment optional) and fail when thresholds unmet.
3. **Release Gates Update** – Modify `Scripts/release_gates.sh` to invoke the coverage helper so local runs mimic CI gating.
4. **Developer Docs** – Document coverage workflow in README/CONTRIBUTING after D2 implementation (prereq for D3 docs task).

## Risks & Mitigations
- **Dependency on C5 artifacts**: If determinism hashing design changes, align coverage harness after C5 merges. _Mitigation:_ keep
  D2 branch rebased on latest determinism implementation and share helper utilities (hashing + diff logs) instead of duplicating.
- **CI Runtime**: Coverage runs add time. _Mitigation:_ reuse build artifacts between `swift test` and coverage job; consider matrix
  reduction (coverage only on Linux). 
- **Toolchain differences**: `llvm-cov` path may differ on macOS vs Linux. _Mitigation:_ detect via `swift --version` or rely on
  SwiftPM-provided `llvm-cov` symlink shipped with toolchain.

## Exit Criteria / Definition of Done
- Coverage report >=90% for CLI + core library targets recorded in CI logs and artifacts.
- Release gates fail fast when coverage <90% and print actionable guidance.
- New/updated tests cover determinism failure paths, Markdown pipeline edges, and CLI flags.
- README (or developer docs) references the coverage workflow (hand-off to D3 once D2 lands).

## Next Actions Before START
1. Capture baseline coverage numbers from current `main` branch (post-C5) for comparison.
2. Draft coverage helper script interface and decide language (Swift script vs Python) to simplify integration.
3. Enumerate exact XCTest cases to add (linking to existing test files) and confirm necessary fixtures exist.
4. Schedule `START` command once C5 implementation PR merges so D2 work can build on deterministic pipeline outputs.

## Status
- **2025-11-18** — Task selected via `SELECT_NEXT`; planning doc created; waiting on C5 completion before START.
