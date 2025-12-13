import XCTest
@testable import Docc2contextCore

final class BenchmarkCommandCLITests: XCTestCase {
    private struct StubBenchmarkRunner: BenchmarkRunning {
        let result: PerformanceBenchmarkHarness.Result

        func run(configuration: PerformanceBenchmarkHarness.Configuration) throws -> PerformanceBenchmarkHarness.Result {
            return result
        }
    }

    private func makeResult(outputDirectory: URL) -> PerformanceBenchmarkHarness.Result {
        let summary = MarkdownGenerationPipeline.Summary(
            outputDirectory: outputDirectory,
            tutorialVolumeCount: 0,
            chapterCount: 0,
            referenceArticleCount: 1,
            symbolCount: 0)
        let sample = PerformanceBenchmarkHarness.Sample(
            iteration: 1,
            durationSeconds: 0.5,
            outputBytes: 512,
            outputFileCount: 1,
            summary: summary)
        return PerformanceBenchmarkHarness.Result(
            samples: [sample],
            averageSeconds: 0.5,
            maxSeconds: 0.5,
            thresholdSeconds: 5.0,
            passed: true,
            outputRoot: outputDirectory)
    }

    func testHelpFlagPrintsUsage() {
        let command = BenchmarkCommand()
        let result = command.run(arguments: ["docc2context-benchmark", "--help"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.output.contains("Usage:"))
    }

    func testMissingFixtureReturnsUsageError() {
        let command = BenchmarkCommand()
        let result = command.run(arguments: ["docc2context-benchmark", "--fixture", "/no/such/fixture"])
        XCTAssertEqual(result.exitCode, 64)
        XCTAssertTrue(result.output.contains("Fixture not found"))
    }

    func testNegativeIterationsReturnsUsageError() {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        let command = BenchmarkCommand()
        let result = command.run(arguments: [
            "docc2context-benchmark",
            "--fixture", fixtureURL.path,
            "--iterations=-1"
        ])

        XCTAssertEqual(result.exitCode, 64)
        XCTAssertTrue(result.output.contains("Iterations must be greater than zero"))
    }

    func testNegativeThresholdReturnsUsageError() {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        let command = BenchmarkCommand()
        let result = command.run(arguments: [
            "docc2context-benchmark",
            "--fixture", fixtureURL.path,
            "--threshold-seconds=-1"
        ])

        XCTAssertEqual(result.exitCode, 64)
        XCTAssertTrue(result.output.contains("Threshold seconds must be greater than zero"))
    }

    func testSuccessfulRunWritesMetricsJSON() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let metricsURL = temporaryDirectory.url.appendingPathComponent("metrics.json")
            let stubResult = makeResult(outputDirectory: temporaryDirectory.url)

            let command = BenchmarkCommand(
                harness: StubBenchmarkRunner(result: stubResult),
                fixtureBuilder: BenchmarkFixtureBuilder(),
                comparator: BenchmarkComparator(),
                fileManager: .default)

            let result = command.run(arguments: [
                "docc2context-benchmark",
                "--fixture", fixtureURL.path,
                "--output", temporaryDirectory.url.path,
                "--metrics-json", metricsURL.path
            ])

            XCTAssertEqual(result.exitCode, 0)
            XCTAssertTrue(FileManager.default.fileExists(atPath: metricsURL.path))

            let data = try Data(contentsOf: metricsURL)
            let decoder = DeterministicJSONEncoder.makeDecoder()
            let metrics = try decoder.decode(PerformanceBenchmarkHarness.BenchmarkMetrics.self, from: data)
            XCTAssertEqual(metrics.averageSeconds, stubResult.averageSeconds)
            XCTAssertEqual(metrics.maxSeconds, stubResult.maxSeconds)
        }
    }
}
