## Summary
- add performance regression comparator + baseline support to `docc2context-benchmark` (baseline file, tolerance flags, fail-on-regression)
- add opt-in Performance Benchmark CI workflow (manual or `perf-check` label) using synthetic 10 MB fixture and uploading metrics
- document baseline usage in README and include deterministic baseline JSON under `Benchmarks/`

## Testing
- swift test
