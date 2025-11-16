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
Created 2025-11-17 during Cycle 3 (SELECT_NEXT phase)
