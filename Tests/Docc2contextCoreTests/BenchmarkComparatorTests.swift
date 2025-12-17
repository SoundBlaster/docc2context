import XCTest
@testable import Docc2contextCore

final class BenchmarkComparatorTests: XCTestCase {
    func testPassesWithinTolerance() {
        let baseline = PerformanceBenchmarkHarness.BenchmarkMetrics(
            fixturePath: "/tmp/baseline",
            fixtureSizeBytes: 10_000_000,
            thresholdSeconds: 10,
            averageSeconds: 1.0,
            maxSeconds: 2.0,
            passed: true,
            samples: [])

        let candidate = PerformanceBenchmarkHarness.BenchmarkMetrics(
            fixturePath: "/tmp/candidate",
            fixtureSizeBytes: 10_000_000,
            thresholdSeconds: 10,
            averageSeconds: 1.9,
            maxSeconds: 3.9,
            passed: true,
            samples: [])

        let tolerance = BenchmarkComparator.Tolerance(
            averageMultiplier: 2.0,
            maxMultiplier: 2.0)

        let result = BenchmarkComparator().compare(
            baseline: baseline,
            candidate: candidate,
            tolerance: tolerance,
            thresholdSeconds: 10)

        XCTAssertTrue(result.passed)
        XCTAssertTrue(result.messages.isEmpty)
    }

    func testFailsWhenMaxExceedsTolerance() {
        let baseline = PerformanceBenchmarkHarness.BenchmarkMetrics(
            fixturePath: "/tmp/baseline",
            fixtureSizeBytes: 10_000_000,
            thresholdSeconds: 10,
            averageSeconds: 1.0,
            maxSeconds: 2.0,
            passed: true,
            samples: [])

        let candidate = PerformanceBenchmarkHarness.BenchmarkMetrics(
            fixturePath: "/tmp/candidate",
            fixtureSizeBytes: 10_000_000,
            thresholdSeconds: 10,
            averageSeconds: 1.5,
            maxSeconds: 5.1,
            passed: true,
            samples: [])

        let tolerance = BenchmarkComparator.Tolerance(
            averageMultiplier: 2.0,
            maxMultiplier: 2.0)

        let result = BenchmarkComparator().compare(
            baseline: baseline,
            candidate: candidate,
            tolerance: tolerance,
            thresholdSeconds: 10)

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.messages.contains { $0.contains("Max duration regression") })
    }

    func testFailsWhenThresholdExceeded() {
        let baseline = PerformanceBenchmarkHarness.BenchmarkMetrics(
            fixturePath: "/tmp/baseline",
            fixtureSizeBytes: 10_000_000,
            thresholdSeconds: 10,
            averageSeconds: 1.0,
            maxSeconds: 2.0,
            passed: true,
            samples: [])

        let candidate = PerformanceBenchmarkHarness.BenchmarkMetrics(
            fixturePath: "/tmp/candidate",
            fixtureSizeBytes: 10_000_000,
            thresholdSeconds: 10,
            averageSeconds: 1.5,
            maxSeconds: 12.5,
            passed: true,
            samples: [])

        let tolerance = BenchmarkComparator.Tolerance(
            averageMultiplier: 3.0,
            maxMultiplier: 3.0)

        let result = BenchmarkComparator().compare(
            baseline: baseline,
            candidate: candidate,
            tolerance: tolerance,
            thresholdSeconds: 10)

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.messages.contains { $0.contains("exceeds configured threshold") })
    }

    func testFailsWhenCandidateOwnThresholdFails() {
        let baseline = PerformanceBenchmarkHarness.BenchmarkMetrics(
            fixturePath: "/tmp/baseline",
            fixtureSizeBytes: 10_000_000,
            thresholdSeconds: 10,
            averageSeconds: 1.0,
            maxSeconds: 2.0,
            passed: true,
            samples: [])

        let candidate = PerformanceBenchmarkHarness.BenchmarkMetrics(
            fixturePath: "/tmp/candidate",
            fixtureSizeBytes: 10_000_000,
            thresholdSeconds: 10,
            averageSeconds: 1.5,
            maxSeconds: 12.5,
            passed: false,
            samples: [])

        let tolerance = BenchmarkComparator.Tolerance(
            averageMultiplier: 3.0,
            maxMultiplier: 3.0)

        let result = BenchmarkComparator().compare(
            baseline: baseline,
            candidate: candidate,
            tolerance: tolerance,
            thresholdSeconds: 10)

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.messages.contains { $0.contains("failed its own threshold") })
    }
}
