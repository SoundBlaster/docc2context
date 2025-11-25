# G0 Test Debt Cleanup — Planning Note

## 📋 Task Overview
- **Task ID**: G0  
- **Title**: Test debt cleanup (XCTSkip warnings + placeholder tests)  
- **Objective**: Remove lingering test debt so `swift test` runs warning-free and skipped cases carry explicit, justified conditions.

## 🔎 Current Context
- F1/F2 completed; `swift test` now surfaces two warnings:
  - `StreamingOptimizationTests.swift:162` — `XCTSkip` initializer result unused (should throw or return).
  - `ReleaseWorkflowE2ETests.swift:136` — code after `throw` marked unreachable (guard + throw ordering).
- Multiple placeholder tests remain (e.g., ArchiveExtraction, InputDetection, Logging, PackageReleaseScript Linux path) that use unconditional skips; some should become real specs or conditional skips with fixtures.

## 🧭 Goals & Success Criteria
- `swift test` emits **zero warnings**.
- All skipped tests either:
  - encode a concrete precondition (e.g., tool availability, platform guard) via `throw XCTSkip(...)`, or
  - are replaced with real, fixture-backed assertions (preferred).
- No new nondeterminism introduced; determinism/coverage gates stay green.

## 🔗 Dependencies & Inputs
- Existing fixtures: `Fixtures/TutorialCatalog.doccarchive`, `Fixtures/ArticleReference.doccarchive`.
- Scripts: `Scripts/build_linux_packages.sh`, `Scripts/release_gates.sh` for packaging-related skips.
- CI expectations: determinism and coverage enforcement remain intact.

## 🧪 Proposed Work (Documentation Only — SELECT_NEXT)
1. Audit all `XCTSkip` usage and warnings; categorize into conditional skip vs. placeholder.
2. Convert warning sites:
   - `StreamingOptimizationTests` to `throw XCTSkip(...)` or gate behind availability.
   - `ReleaseWorkflowE2ETests` guard path to use `XCTSkip` without unreachable code.
3. Prioritize converting placeholder tests to real cases where fixtures exist (ArchiveExtraction/InputDetection/Logging).
4. Retain conditional skips for host-dependent packaging tests (dpkg-deb, Linux-only) with clear messages.
5. Run `swift test` locally to confirm warning-free output and document results.

## 📌 Deliverables (for START)
- Implemented test updates per above.
- Updated skip rationale documented inline.
- Validation log: `swift test` with zero warnings.

## 📅 Status
- **State**: Selected (planning only — no code written)  
- **Owner**: docc2context agent  
- **Date**: 2025-11-25
