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

    func testSynthesizedFixtureReplacesExistingOutput() throws {
        let baseFixture = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let builder = BenchmarkFixtureBuilder()
            let targetBytes = 50_000

            // Create first synthesized fixture
            let firstFixture = try builder.synthesizeBenchmarkFixture(
                baseFixtureURL: baseFixture,
                targetSizeBytes: targetBytes,
                destinationDirectory: temporaryDirectory.url)

            // Create second fixture with same destination - should replace the first
            let secondFixture = try builder.synthesizeBenchmarkFixture(
                baseFixtureURL: baseFixture,
                targetSizeBytes: targetBytes * 2,
                destinationDirectory: temporaryDirectory.url)

            XCTAssertEqual(firstFixture.path, secondFixture.path)
            let finalSize = try BenchmarkFixtureBuilder.directorySize(at: secondFixture)
            XCTAssertGreaterThanOrEqual(finalSize, targetBytes * 2)
        }
    }

    func testBenchmarkWithMultipleIterationsReusesDirectory() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let outputDirectory = temporaryDirectory.childDirectory(named: "benchmark-output")

            // Pre-create an iteration directory to test cleanup path
            let iterationDir = outputDirectory.appendingPathComponent("iteration-1", isDirectory: true)
            try FileManager.default.createDirectory(at: iterationDir, withIntermediateDirectories: true)
            try "old data".write(to: iterationDir.appendingPathComponent("test.txt"), atomically: true, encoding: .utf8)

            let configuration = PerformanceBenchmarkHarness.Configuration(
                fixtureURL: fixtureURL,
                iterations: 1,
                thresholdSeconds: 5.0,
                outputDirectory: outputDirectory,
                keepOutputs: false)

            let harness = PerformanceBenchmarkHarness()
            let result = try harness.run(configuration: configuration)

            XCTAssertTrue(result.passed)
            // Verify old data was cleaned up
            let testFile = iterationDir.appendingPathComponent("test.txt")
            XCTAssertFalse(FileManager.default.fileExists(atPath: testFile.path))
        }
    }

    func testDirectorySizeReturnsZeroForNonexistentDirectory() throws {
        let nonexistent = URL(fileURLWithPath: "/nonexistent/path/\(UUID().uuidString)")
        let size = try BenchmarkFixtureBuilder.directorySize(at: nonexistent)
        XCTAssertEqual(size, 0, "Nonexistent directory should return size 0")
    }

    func testBenchmarkResultProducesMetrics() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let outputDirectory = temporaryDirectory.childDirectory(named: "benchmark-output")
            let configuration = PerformanceBenchmarkHarness.Configuration(
                fixtureURL: fixtureURL,
                iterations: 2,
                thresholdSeconds: 10.0,
                outputDirectory: outputDirectory,
                keepOutputs: false)

            let harness = PerformanceBenchmarkHarness()
            let result = try harness.run(configuration: configuration)

            let fixtureSize = try BenchmarkFixtureBuilder.directorySize(at: fixtureURL)
            let metrics = result.makeMetrics(fixtureURL: fixtureURL, fixtureSizeBytes: fixtureSize)

            XCTAssertEqual(metrics.fixturePath, fixtureURL.path)
            XCTAssertEqual(metrics.fixtureSizeBytes, fixtureSize)
            XCTAssertEqual(metrics.thresholdSeconds, 10.0)
            XCTAssertEqual(metrics.averageSeconds, result.averageSeconds)
            XCTAssertEqual(metrics.maxSeconds, result.maxSeconds)
            XCTAssertEqual(metrics.passed, result.passed)
            XCTAssertEqual(metrics.samples.count, 2)

            let firstSample = metrics.samples[0]
            XCTAssertEqual(firstSample.iteration, 1)
            XCTAssertGreaterThan(firstSample.durationSeconds, 0)
            XCTAssertGreaterThan(firstSample.outputBytes, 0)
            XCTAssertGreaterThan(firstSample.outputFileCount, 0)

            // Verify metrics can be encoded and decoded
            let encoder = DeterministicJSONEncoder.makeEncoder()
            let data = try encoder.encode(metrics)
            XCTAssertGreaterThan(data.count, 0)

            let decoder = DeterministicJSONEncoder.makeDecoder()
            let decoded = try decoder.decode(PerformanceBenchmarkHarness.BenchmarkMetrics.self, from: data)
            XCTAssertEqual(decoded.fixturePath, metrics.fixturePath)
            XCTAssertEqual(decoded.samples.count, metrics.samples.count)
        }
    }

    func testDirectorySizeHandlesVariousFileTypes() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            // Create some test files
            let file1 = temporaryDirectory.url.appendingPathComponent("test1.txt")
            try "content".write(to: file1, atomically: true, encoding: .utf8)

            let file2 = temporaryDirectory.url.appendingPathComponent("test2.json")
            try "{\"key\": \"value\"}".write(to: file2, atomically: true, encoding: .utf8)

            let subdir = temporaryDirectory.childDirectory(named: "subdir")
            try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true)
            let file3 = subdir.appendingPathComponent("test3.md")
            try "# Header".write(to: file3, atomically: true, encoding: .utf8)

            let size = try BenchmarkFixtureBuilder.directorySize(at: temporaryDirectory.url)
            XCTAssertGreaterThan(size, 0, "Directory size should include all files")
        }
    }
}
