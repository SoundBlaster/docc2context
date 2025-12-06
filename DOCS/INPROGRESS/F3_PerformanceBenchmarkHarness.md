# F3 – Performance Benchmark Harness (Planning)

**Status:** Planning (SELECT_NEXT)
**Date:** 2025-12-06
**Owner:** docc2context agent
**Depends On:** C5 determinism validator (complete), D2 coverage gate (complete), F1 streaming optimizations (complete)

---

## 🎯 Intent

Design a repeatable benchmarking harness that validates the PRD performance target of converting a ~10 MB DocC bundle within 10 seconds on modern Apple Silicon hardware (M1/M2, 16 GB RAM). The harness should quantify runtime without compromising determinism or CI stability and provide guidance for when and how to execute the check (e.g., optional gate or scheduled job).

---

## ✅ Selection Rationale
- **Phase integrity:** Phase A–D foundations plus F1 optimizations are complete; adding a performance benchmark is the next logical enhancement to enforce the PRD runtime goal without changing feature behavior.
- **Dependency awareness:** Relies on existing release gates (`Scripts/release_gates.sh`), determinism hashing (C5), and current fixtures; no new parsing/generation code required.
- **Testing first:** Planning will outline benchmark tests and fixtures (potentially synthesized to ~10 MB) before any implementation to ensure TDD alignment.
- **Doc sync:** Results and expectations will feed README/PRD notes so performance guidance matches reality.

---

## 📐 Scope for START
When START is invoked, implement the following:
1. **Benchmark fixture:** Assemble or synthesize a deterministic DocC bundle around 10 MB (could extend existing fixtures with duplicated articles) with manifest hashes recorded for integrity.
2. **Benchmark runner:** Add a script (e.g., `Scripts/benchmark_conversion.sh`) or XCTest that runs the full CLI pipeline against the benchmark fixture, capturing wall-clock runtime, CPU, and memory metrics (building atop `Scripts/profile_memory.sh` where possible).
3. **Threshold enforcement:** Define pass/fail criteria aligned to the PRD target (≤10s on M1/M2) with headroom and platform notes; expose an opt-in flag for CI to avoid flaky timing on shared runners.
4. **Reporting:** Emit structured output (JSON/Markdown) suitable for artifacts and documentation, including deterministic hashes to keep runs comparable.
5. **Documentation:** Update README/PRD annotations with how to run the benchmark locally, interpretation guidance, and how it fits into release gates or periodic checks.

---

## 🔎 Current State Check
- **TODO:** No "Ready to Start" entries; this note adds an actionable planning item to keep performance work moving.
- **INPROGRESS:** F1 optimization archive plus `Scripts/profile_memory.sh` provide memory-focused profiling, but no runtime benchmark or gate exists.
- **ARCHIVE:** C5 determinism and D2 coverage gates confirm stability for repeated conversions; workplan shows Phase F enhancements are the active area for incremental quality improvements.

---

## 📋 Proposed Plan (No code yet)
- **Fixture design:** Evaluate current DocC fixtures; if size is insufficient, script deterministic expansion (duplicated tutorials/articles) to hit ~10 MB without altering semantics. Capture hashes in fixture manifest.
- **Runner design:** Prototype command shape (`--iterations`, `--time-limit`, `--metrics-output`) and logging format for a benchmark script or test; ensure it reuses existing pipeline entry points to mirror real usage.
- **Environment guidance:** Document expected hardware baselines and how to adjust thresholds for CI vs. local runs to avoid flaky failures.
- **Validation strategy:** Decide whether the benchmark runs as an optional CI job (e.g., nightly) or manual pre-release gate; outline how results are stored (artifacts, logs) and how regressions will be triaged.
- **Risk mitigation:** Plan fallbacks if the 10-second goal is missed (e.g., flagging regression, profiling checklist, feature toggles) without blocking releases unnecessarily.

---

## 🚧 Blockers & Risks
- **Timing variance:** Shared CI runners may not meet the PRD hardware baseline; gating must be opt-in or calibrated to avoid false failures.
- **Fixture maintenance:** Larger fixtures increase repository size; need to balance realism with repo bloat and download time.
- **Determinism:** Benchmark outputs (hashes/metrics) must remain deterministic when inputs are unchanged; non-deterministic timing noise should be isolated from hashes.

---

## 🔜 Next Actions Before START
- Keep `DOCS/todo.md` updated with this planning entry (done alongside this note).
- Draft benchmark fixture options and size estimates; propose whether to expand existing fixtures or add a new synthetic bundle.
- Sketch the CLI interface and output format for the benchmark runner so implementation can begin immediately after START.

