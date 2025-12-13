import XCTest
@testable import Docc2contextCore

final class PerformanceBenchmarkHarnessTests: XCTestCase {

    func testBenchmarkProducesMetricsAndPassesThreshold() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let outputDirectory = temporaryDirectory.childDirectory(named: "benchmark-output")
            let configuration = PerformanceBenchmarkHarness.Configuration(
                fixtureURL: fixtureURL,
                iterations: 1,
                thresholdSeconds: 5.0,
                outputDirectory: outputDirectory,
                keepOutputs: false)

            let harness = PerformanceBenchmarkHarness()
            let result = try harness.run(configuration: configuration)

            XCTAssertTrue(result.passed, "Benchmark should pass under the generous threshold")
            XCTAssertEqual(result.samples.count, 1)
            XCTAssertLessThanOrEqual(result.maxSeconds, result.thresholdSeconds)

            let sample = try XCTUnwrap(result.samples.first)
            XCTAssertGreaterThan(sample.durationSeconds, 0.0)
            XCTAssertGreaterThan(sample.outputBytes, 0)
            XCTAssertGreaterThan(sample.outputFileCount, 0)
        }
    }

    func testBenchmarkFailsWhenThresholdIsTooLow() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let outputDirectory = temporaryDirectory.childDirectory(named: "benchmark-output")
            let configuration = PerformanceBenchmarkHarness.Configuration(
                fixtureURL: fixtureURL,
                iterations: 1,
                thresholdSeconds: 0.0001,
                outputDirectory: outputDirectory,
                keepOutputs: false)

            let harness = PerformanceBenchmarkHarness()
            let result = try harness.run(configuration: configuration)

            XCTAssertFalse(result.passed, "Extremely low threshold should fail even fast runs")
            XCTAssertGreaterThan(result.maxSeconds, result.thresholdSeconds)
            XCTAssertEqual(result.samples.count, 1)
        }
    }

    func testSynthesizedFixtureMeetsTargetSizeAndConverts() throws {
        let baseFixture = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let builder = BenchmarkFixtureBuilder()
            let targetBytes = 120_000 // ~0.12 MB to keep test execution quick
            let synthesizedFixture = try builder.synthesizeBenchmarkFixture(
                baseFixtureURL: baseFixture,
                targetSizeBytes: targetBytes,
                destinationDirectory: temporaryDirectory.url)

            let synthesizedSize = try BenchmarkFixtureBuilder.directorySize(at: synthesizedFixture)
            XCTAssertGreaterThanOrEqual(
                synthesizedSize,
                targetBytes,
                "Synthesized fixture should meet or exceed the requested size")

            let outputDirectory = temporaryDirectory.childDirectory(named: "benchmark-output")
            let configuration = PerformanceBenchmarkHarness.Configuration(
                fixtureURL: synthesizedFixture,
                iterations: 1,
                thresholdSeconds: 5.0,
                outputDirectory: outputDirectory,
                keepOutputs: false)

            let harness = PerformanceBenchmarkHarness()
            let result = try harness.run(configuration: configuration)

            XCTAssertTrue(result.passed, "Benchmark on synthesized fixture should succeed under generous threshold")
            XCTAssertGreaterThan(result.samples.first?.outputFileCount ?? 0, 0)
        }
    }
}
