# F1 Incremental Conversion — Planning (SELECT_NEXT)

## Context
- Phase A–E deliverables are archived; only E3 notarization remains externally blocked, leaving the pipeline stable but memory usage unoptimized for very large DocC archives.
- Current Markdown/link graph generation walks the entire bundle before writing outputs, which risks high peak memory on multi-GB documentation sets.
- This task originates from the Backlog/Under Consideration queue to evaluate streaming/segmented conversion strategies without compromising determinism locked in C5.

## Objectives & Success Criteria
- Reduce peak memory requirements for large DocC bundles via streaming or chunked generation while keeping outputs byte-identical to existing snapshots.
- Maintain determinism gates (C5) and structured logging/exit codes (D1) across both baseline and streaming code paths.
- Preserve CLI ergonomics (`docc2context convert ...`) with no flag regressions; any new flags must include failing tests first.
- Provide measurable evidence (profiling notes and, if feasible, performance tests) that peak memory decreases or remains bounded relative to bundle size.

## Dependencies & Constraints
- Determinism and snapshot parity from Phase C/C5 cannot regress; any concurrency or buffering strategy must keep ordering stable.
- Requires profiling instrumentation or scripts to baseline current memory/time on large fixtures before changing the pipeline.
- May require new synthetic large-bundle fixture(s); ensure provenance + manifest hashes align with A3 fixture discipline.
- Release gates (`Scripts/release_gates.sh`) and CI jobs should continue to pass; new checks may be added but not removed.

## Proposed Approach (for START execution)
1. **Baseline Profiling**
   - Add a repeatable profiling helper (Swift or shell) to measure peak RSS/time for `docc2context` on existing fixtures; record numbers in the INPROGRESS log.
2. **Design Streaming Plan**
   - Identify pipeline seams for chunking (DocC data ingestion, Markdown rendering, link graph emission) while preserving deterministic ordering and existing log messages.
   - Decide whether to gate streaming behind a feature flag or make it default once parity is proven.
3. **Spec/Tests First**
   - Author failing tests that validate identical outputs between streaming and current path (snapshot hashes) and, if possible, guard against unbounded memory via configurable limits or mock metrics.
4. **Implementation Outline**
   - Introduce streaming writers/readers with buffered I/O and back-pressure; keep interfaces stable for CLI and `Docc2contextCore` consumers.
   - Extend logging to surface streaming progress without changing existing message formats; add new fields only when guarded.
5. **Validation & Gates**
   - Re-run determinism suite, coverage gate, and release gates; compare profiling results to baseline to confirm improvements.

## Open Questions
- What bundle size threshold triggers unacceptable memory growth on current pipeline? Need empirical data from profiling helper.
- Should streaming be opt-in (e.g., `--stream`) initially to limit regression risk, or should it replace the default path after parity validation?
- How to simulate multi-GB inputs in CI without ballooning repository size—generate fixtures on the fly or downsample existing ones?

## Next Steps
- Keep this task in `In Progress` until profiling data and failing parity tests are drafted, then switch to the START command for implementation.
- Update `DOCS/todo.md` and this note with profiling findings, selected flag strategy (opt-in vs. default), and test/fixture plan before coding.
