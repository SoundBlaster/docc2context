# C5 – Verify Determinism (Cycle 3 Selection)

## Overview
Add CI job executing conversion twice and hashing outputs to confirm byte-identical results. Expose script/command for developers to rerun determinism locally before PRs. Log summary of differences when determinism fails to speed up debugging.

## Objective
Complete C5 task as part of cyclic execution workflow:
1. Author failing determinism tests
2. Implement determinism verification in release gates
3. Add CI job for double-conversion hashing
4. Document local determinism validation workflow

## PRD References
- **Phase C, Task C5:** Verify Determinism — double-run conversions in CI and compare hashes.
- **Acceptance Criteria:**
  - Consecutive runs produce identical outputs
  - Hash comparison validates byte-for-byte equivalence
  - CI job gates releases on determinism pass
  - Developer documentation for local validation

## Dependencies
- ✅ Phase C1-C4 – All Markdown generation tasks (when complete)

## Test Plan
1. **Determinism Tests**:
   - Test: same bundle → same markdown files (hash comparison)
   - Test: same bundle → same link graph JSON
   - Test: same bundle → same TOC/index files

2. **Release Gates**:
   - Add determinism check to Scripts/release_gates.sh
   - Hash all generated files
   - Compare with second run

3. **CI Integration**:
   - GitHub Actions job runs conversion twice
   - Compares output directory hashes
   - Fails if hashes don't match

## Implementation Scope
- Create `DeterminismValidator` for file hashing
- Extend `Scripts/release_gates.sh` with file-level hashing
- Add CI job to `.github/workflows/ci.yml`
- Document workflow in README

## Success Metrics
- ✅ Determinism tests pass
- ✅ Release gates validate determinism
- ✅ CI job gates on determinism verification
- ✅ Developer docs complete
- ✅ Ready for Phase D

## Status
**COMPLETE** — 2025-11-16

## Implementation Summary

### What Was Implemented

1. **DeterminismValidator Class** (`Sources/Docc2contextCore/DeterminismValidator.swift`)
   - Provides utilities for hashing files and directories
   - Implements `compareDirectories()` method that compares two directory trees byte-for-byte
   - Returns detailed `DeterminismResult` with differences and hashes
   - Uses deterministic hash algorithm that processes files in sorted order

2. **DeterminismTests** (`Tests/Docc2contextCoreTests/DeterminismTests.swift`)
   - **test_consecutiveRunsProduceIdenticalMarkdownFiles** – Verifies two consecutive conversion runs produce byte-identical output
   - **test_linkGraphIsDeterministic** – Verifies link graph JSON is generated identically
   - **test_tocAndIndexAreDeterministic** – Verifies TOC and index files are deterministic
   - **test_determinismValidatorDetectsDifferences** – Verifies validator correctly identifies content differences
   - **test_hashingIsConsistent** – Verifies hash computation is stable

   All 5 tests pass, confirming existing code already produces deterministic outputs.

3. **Extended Release Gates Script** (`Scripts/release_gates.sh`)
   - Added `run_full_determinism_check()` function
   - Converts TutorialCatalog fixture twice to separate directories
   - Compares all generated files byte-for-byte using SHA-256 checksums
   - Reports detailed errors if any differences are found
   - Integrated into main() execution flow

4. **CI Job for Determinism** (`.github/workflows/ci.yml`)
   - Added new `determinism` job that runs on Ubuntu 22.04
   - Builds project and executes full release gates script
   - Separate job makes determinism validation explicitly visible in CI
   - Runs on every push and pull request

5. **Documentation Updates** (`README.md`)
   - Documented full determinism verification workflow
   - Explained DeterminismValidator utilities and capabilities
   - Added section on determinism testing and validation
   - Updated release gates description with all checks performed

### Test Results

```
Test Suite 'DeterminismTests' passed
  Executed 5 tests, with 0 failures (0 unexpected)
```

Total test suite: 55 tests pass (50 existing + 5 new)

### Verification

- ✅ All new determinism tests pass (prove existing code is deterministic)
- ✅ All existing tests still pass (no regressions)
- ✅ Release gates script extended with full output checking
- ✅ CI job configured for determinism verification
- ✅ Documentation updated with determinism workflow
- ✅ Code follows project conventions and patterns

### Key Design Decisions

1. **Deterministic Hashing** – Used simple but effective hashing algorithm that processes files in sorted order to guarantee deterministic results across runs (not dependent on filesystem ordering).

2. **Test-First Validation** – All 5 tests were written to validate determinism before implementation. Tests passing proves existing code is already deterministic.

3. **Separate CI Job** – Created explicit `determinism` job in CI to make determinism validation visible as a first-class concern in release process.

4. **Release Gates Integration** – Extended existing release gates script rather than creating new validation script, keeping pre-release checks consolidated.

### Ready for Phase D

C5 is now complete and ready for:
- D2 Harden Test Coverage – Can now leverage determinism validation in coverage infrastructure
- D3 Documentation – Can document determinism as core quality gate
- D4 Packaging – Can ensure releases only publish after determinism verification

Created 2025-11-17 during Cycle 3 (SELECT_NEXT phase)
Completed 2025-11-16 during Cycle 3 (START phase)
