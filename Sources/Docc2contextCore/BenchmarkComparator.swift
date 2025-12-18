import Foundation

/// Compares benchmark results against a baseline and produces human-readable regression messages.
///
/// This helper is used by the `docc2context-benchmark` executable and CI workflows to detect performance
/// regressions over time without requiring external benchmarking infrastructure.
///
/// The comparator operates on aggregated timing metrics (average/max seconds) and applies independent
/// multipliers to the average and max thresholds so projects can tune how strict performance gating should be.
public struct BenchmarkComparator {
    public struct Tolerance {
        public let averageMultiplier: Double
        public let maxMultiplier: Double

        public init(averageMultiplier: Double, maxMultiplier: Double) {
            self.averageMultiplier = averageMultiplier
            self.maxMultiplier = maxMultiplier
        }
    }

    public struct Result {
        public let passed: Bool
        public let messages: [String]
    }

    public init() {}

    public func compare(
        baseline: PerformanceBenchmarkHarness.BenchmarkMetrics,
        candidate: PerformanceBenchmarkHarness.BenchmarkMetrics,
        tolerance: Tolerance,
        thresholdSeconds: TimeInterval
    ) -> Result {
        var messages: [String] = []

        if !candidate.passed {
            messages.append("Candidate benchmark failed its own threshold (max \(candidate.maxSeconds)s over limit \(candidate.thresholdSeconds)s).")
        }

        if candidate.maxSeconds > thresholdSeconds {
            messages.append("Max duration \(String(format: "%.3f", candidate.maxSeconds))s exceeds configured threshold \(String(format: "%.3f", thresholdSeconds))s.")
        }

        if baseline.averageSeconds > 0 && candidate.averageSeconds > baseline.averageSeconds * tolerance.averageMultiplier {
            messages.append("Average duration regression: baseline \(String(format: "%.3f", baseline.averageSeconds))s -> \(String(format: "%.3f", candidate.averageSeconds))s (tolerance x\(tolerance.averageMultiplier)).")
        }

        if baseline.maxSeconds > 0 && candidate.maxSeconds > baseline.maxSeconds * tolerance.maxMultiplier {
            messages.append("Max duration regression: baseline \(String(format: "%.3f", baseline.maxSeconds))s -> \(String(format: "%.3f", candidate.maxSeconds))s (tolerance x\(tolerance.maxMultiplier)).")
        }

        return Result(passed: messages.isEmpty, messages: messages)
    }
}
