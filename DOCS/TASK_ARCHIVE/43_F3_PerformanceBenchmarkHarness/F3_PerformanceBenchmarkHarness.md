# F3 – Performance Benchmark Harness

**Status:** Complete  
**Completion Date:** 2025-12-13  
**Owner:** docc2context agent  
**Related PRD:** Non-functional performance target (≤10s for ~10 MB bundles on modern Apple Silicon)

## Summary
- Implemented `PerformanceBenchmarkHarness` to run the full Markdown pipeline repeatedly and report per-iteration wall-clock durations, output file counts, and byte sizes.
- Added `BenchmarkFixtureBuilder` to synthesize a larger DocC bundle from the `ArticleReference` fixture via deterministic article payload inflation (no new external assets).
- Introduced the `docc2context-benchmark` executable with options for fixture selection, `--synthesize-megabytes <N>`, JSON metrics export, and `--keep-output` controls.
- Documented harness usage in `README.md` (new “Performance benchmarking” section) and fixture synthesis behavior in `Fixtures/README.md`.

## Validation
- New XCTest coverage: `PerformanceBenchmarkHarnessTests` (3 cases) covering threshold pass/fail, metrics reporting, and synthetic bundle conversion.
- Full test suite: `swift test --disable-sandbox` with local cache overrides (`SWIFTPM_DISABLE_PLUGINS=1 SWIFTPM_CACHE_PATH=$(pwd)/.build/swiftpm-cache CLANG_MODULE_CACHE_PATH=$(pwd)/.build/ModuleCache TMPDIR=$(pwd)/.build/tmp`) — 126 tests, 9 skipped, 0 failures.

## Usage Notes
- Default invocation benchmarks the ArticleReference fixture; pass `--fixture <path>` to target a custom DocC bundle.
- `--synthesize-megabytes <N>` inflates the ArticleReference fixture into a temporary bundle of roughly N MB for realistic runtime checks; outputs remain deterministic and offline-friendly.
- `--metrics-json <path>` persists per-iteration metrics (durations, output sizes, summary counts) for CI artifacts or local regression tracking.

## Follow-ups
- Optionally wire the harness into CI as an opt-in/nightly job once timing variance on shared runners is characterized.
- Consider adding a “quick” mode that samples a single iteration for PR feedback while leaving multi-iteration runs for release candidates.
