# Coverage gate on Linux reported ~50% (regions) instead of expected line coverage

## Context
- CI run logs: `DOCS/INPROGRESS/logs_52409162056/`
- Workflow involved: `.github/workflows/coverage-gate.yml`

## Symptom
The Linux “Coverage Gate” job failed with:
- `Coverage 52.75%%`

## Root cause
The workflow labeled its check “line coverage”, but it was reading column `$4` from `llvm-cov report`.

`llvm-cov report` prints multiple coverage dimensions (regions, functions, lines). In the default table layout, `$4` corresponds to **region coverage**, not line coverage. Region coverage can be much lower than line coverage even when tests are healthy.

Additionally, the job’s discovery of `default.profdata` and the test binary was brittle (`find ... | head -n1` for `.profdata`, hard-coded `.build/debug/...` path for the test binary), making the gate sensitive to toolchain layout differences.

## Fix
- Updated `.github/workflows/coverage-gate.yml` to:
  - Discover `default.profdata` and `docc2contextPackageTests.xctest` robustly via `find`.
  - Keep generating `coverage.txt`/`coverage.lcov`/HTML artifacts with `llvm-cov`.
  - Enforce **line coverage** using `Scripts/enforce_coverage.py` with explicit `--profdata` and `--binary` and a `--target Docc2contextCore=Sources/Docc2contextCore`.
- Updated `Scripts/enforce_coverage.py` to fall back to locating `.build/**/codecov/default.profdata` when `.build/debug/codecov/default.profdata` is absent.

## Expected outcome
Linux coverage gates stop failing due to low region coverage and instead enforce the intended **line coverage** threshold for `Docc2contextCore`.

