import XCTest
@testable import Docc2contextCore

final class BenchmarkCommandBaselineTests: XCTestCase {
    private struct StubBenchmarkRunner: BenchmarkRunning {
        let result: PerformanceBenchmarkHarness.Result

        func run(configuration: PerformanceBenchmarkHarness.Configuration) throws -> PerformanceBenchmarkHarness.Result {
            return result
        }
    }

    func testBaselineRegressionFailsWhenRequested() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            // Prepare baseline metrics
            let baselineMetrics = PerformanceBenchmarkHarness.BenchmarkMetrics(
                fixturePath: "/tmp/baseline",
                fixtureSizeBytes: 10_000_000,
                thresholdSeconds: 10,
                averageSeconds: 1.0,
                maxSeconds: 2.0,
                passed: true,
                samples: [])
            let encoder = DeterministicJSONEncoder.makeEncoder()
            let baselineData = try encoder.encode(baselineMetrics)
            let baselineURL = temporaryDirectory.url.appendingPathComponent("baseline.json")
            try baselineData.write(to: baselineURL)

            // Stub runner returns slower candidate
            let summary = MarkdownGenerationPipeline.Summary(
                outputDirectory: temporaryDirectory.url,
                tutorialVolumeCount: 0,
                chapterCount: 0,
                referenceArticleCount: 1,
                symbolCount: 0)
            let sample = PerformanceBenchmarkHarness.Sample(
                iteration: 1,
                durationSeconds: 5.5,
                outputBytes: 1024,
                outputFileCount: 2,
                summary: summary)
            let result = PerformanceBenchmarkHarness.Result(
                samples: [sample],
                averageSeconds: 5.5,
                maxSeconds: 5.5,
                thresholdSeconds: 10,
                passed: true,
                outputRoot: temporaryDirectory.url)

            let stubRunner = StubBenchmarkRunner(result: result)
            let command = BenchmarkCommand(
                harness: stubRunner,
                fixtureBuilder: BenchmarkFixtureBuilder(),
                comparator: BenchmarkComparator(),
                fileManager: .default)

            let metricsPath = temporaryDirectory.url.appendingPathComponent("metrics.json")

            let arguments = [
                "docc2context-benchmark",
                "--fixture", fixtureURL.path,
                "--baseline", baselineURL.path,
                "--tolerance-average", "1.5",
                "--tolerance-max", "1.5",
                "--fail-on-regression",
                "--output", temporaryDirectory.url.path,
                "--metrics-json", metricsPath.path
            ]

            let resultCommand = command.run(arguments: arguments)

            if resultCommand.exitCode == 64 {
                XCTFail("Unexpected CLI error: \(resultCommand.output)")
                return
            }
            XCTAssertEqual(resultCommand.exitCode, 1, "Regression should trigger non-zero exit when fail-on-regression is set.")
            XCTAssertTrue(resultCommand.output.contains("Regression checks"), "Output should surface regression details.")
        }
    }

    func testBaselineMissingReturnsUsageError() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let summary = MarkdownGenerationPipeline.Summary(
                outputDirectory: temporaryDirectory.url,
                tutorialVolumeCount: 0,
                chapterCount: 0,
                referenceArticleCount: 0,
                symbolCount: 0)
            let sample = PerformanceBenchmarkHarness.Sample(
                iteration: 1,
                durationSeconds: 0.1,
                outputBytes: 128,
                outputFileCount: 1,
                summary: summary)
            let result = PerformanceBenchmarkHarness.Result(
                samples: [sample],
                averageSeconds: 0.1,
                maxSeconds: 0.1,
                thresholdSeconds: 1.0,
                passed: true,
                outputRoot: temporaryDirectory.url)

            let stubRunner = StubBenchmarkRunner(result: result)
            let command = BenchmarkCommand(
                harness: stubRunner,
                fixtureBuilder: BenchmarkFixtureBuilder(),
                comparator: BenchmarkComparator(),
                fileManager: .default)

            let missingBaseline = temporaryDirectory.url.appendingPathComponent("missing.json")
            let arguments = [
                "docc2context-benchmark",
                "--fixture", fixtureURL.path,
                "--baseline", missingBaseline.path,
                "--output", temporaryDirectory.url.path
            ]

            let resultCommand = command.run(arguments: arguments)
            XCTAssertEqual(resultCommand.exitCode, 64)
            XCTAssertTrue(resultCommand.output.contains("Baseline file not found"))
        }
    }

    func testInvalidBaselineReturnsUsageError() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let invalidBaseline = temporaryDirectory.url.appendingPathComponent("invalid.json")
            try "not-json".write(to: invalidBaseline, atomically: true, encoding: .utf8)

            let summary = MarkdownGenerationPipeline.Summary(
                outputDirectory: temporaryDirectory.url,
                tutorialVolumeCount: 0,
                chapterCount: 0,
                referenceArticleCount: 0,
                symbolCount: 0)
            let sample = PerformanceBenchmarkHarness.Sample(
                iteration: 1,
                durationSeconds: 0.1,
                outputBytes: 128,
                outputFileCount: 1,
                summary: summary)
            let result = PerformanceBenchmarkHarness.Result(
                samples: [sample],
                averageSeconds: 0.1,
                maxSeconds: 0.1,
                thresholdSeconds: 1.0,
                passed: true,
                outputRoot: temporaryDirectory.url)

            let command = BenchmarkCommand(
                harness: StubBenchmarkRunner(result: result),
                fixtureBuilder: BenchmarkFixtureBuilder(),
                comparator: BenchmarkComparator(),
                fileManager: .default)

            let arguments = [
                "docc2context-benchmark",
                "--fixture", fixtureURL.path,
                "--baseline", invalidBaseline.path,
                "--output", temporaryDirectory.url.path
            ]

            let resultCommand = command.run(arguments: arguments)
            XCTAssertEqual(resultCommand.exitCode, 64)
            XCTAssertTrue(resultCommand.output.contains("Baseline file is invalid"))
        }
    }

    func testNegativeToleranceReturnsUsageError() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let summary = MarkdownGenerationPipeline.Summary(
                outputDirectory: temporaryDirectory.url,
                tutorialVolumeCount: 0,
                chapterCount: 0,
                referenceArticleCount: 0,
                symbolCount: 0)
            let sample = PerformanceBenchmarkHarness.Sample(
                iteration: 1,
                durationSeconds: 0.1,
                outputBytes: 128,
                outputFileCount: 1,
                summary: summary)
            let result = PerformanceBenchmarkHarness.Result(
                samples: [sample],
                averageSeconds: 0.1,
                maxSeconds: 0.1,
                thresholdSeconds: 1.0,
                passed: true,
                outputRoot: temporaryDirectory.url)

            let command = BenchmarkCommand(
                harness: StubBenchmarkRunner(result: result),
                fixtureBuilder: BenchmarkFixtureBuilder(),
                comparator: BenchmarkComparator(),
                fileManager: .default)

            let arguments = [
                "docc2context-benchmark",
                "--fixture", fixtureURL.path,
                "--tolerance-average=-1",
                "--output", temporaryDirectory.url.path
            ]

            let resultCommand = command.run(arguments: arguments)
            XCTAssertEqual(resultCommand.exitCode, 64)
            XCTAssertTrue(resultCommand.output.contains("Tolerance multipliers must be greater than zero."))
        }
    }
}
