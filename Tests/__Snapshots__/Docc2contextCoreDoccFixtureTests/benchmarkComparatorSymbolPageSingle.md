# BenchmarkComparator

## Symbol Metadata
- **Identifier:** doc://Docc2contextCore/documentation/Docc2contextCore/BenchmarkComparator
- **Module:** Docc2contextCore
- **Symbol Kind:** struct
- **Role Heading:** Structure
- **Catalog Identifier:** doc://Docc2contextCore/documentation/Docc2contextCore
- **Catalog Title:** Docc2contextCore

## Summary
Compares benchmark results against a baseline and produces human-readable regression messages.

## Discussion

### Overview

This helper is used by the `docc2context-benchmark` executable and CI workflows to detect performance regressions over time without requiring external benchmarking infrastructure.

The comparator operates on aggregated timing metrics (average/max seconds) and applies independent multipliers to the average and max thresholds so projects can tune how strict performance gating should be.

## Declarations
```swift
struct BenchmarkComparator
```

## Topics

### Structures
- BenchmarkComparator.Result
- BenchmarkComparator.Tolerance

### Initializers
- init()

### Instance Methods
- compare(baseline:candidate:tolerance:thresholdSeconds:)
