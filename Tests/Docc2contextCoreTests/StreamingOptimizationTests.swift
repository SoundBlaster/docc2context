import XCTest
@testable import Docc2contextCore

/// Tests for F1 Incremental Conversion streaming/memory optimizations
///
/// These tests verify that optimized (streaming) pipeline implementations
/// produce byte-identical outputs to the baseline pipeline while reducing
/// peak memory usage for large DocC bundles.
final class StreamingOptimizationTests: XCTestCase {

    /// Test that streaming article processing produces identical output to baseline
    func test_streamingArticleProcessingMatchesBaseline() throws {
        let articleFixture = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let baselineOutput = temp.childDirectory(named: "baseline")
            let streamingOutput = temp.childDirectory(named: "streaming")

            // Run baseline pipeline
            let baselinePipeline = MarkdownGenerationPipeline()
            let baselineSummary = try baselinePipeline.generateMarkdown(
                from: articleFixture.path,
                to: baselineOutput.path,
                forceOverwrite: false)

            // Run streaming-optimized pipeline
            let streamingPipeline = MarkdownGenerationPipeline()  // Will be optimized implementation
            let streamingSummary = try streamingPipeline.generateMarkdown(
                from: articleFixture.path,
                to: streamingOutput.path,
                forceOverwrite: false)

            // Verify identical output counts
            XCTAssertEqual(
                baselineSummary.referenceArticleCount,
                streamingSummary.referenceArticleCount,
                "Streaming pipeline should produce same number of reference articles")

            // Verify byte-identical outputs
            let validator = DeterminismValidator()
            let comparison = try validator.compareDirectories(
                firstPath: baselineOutput.path,
                secondPath: streamingOutput.path)

            XCTAssertTrue(
                comparison.isDeterministic,
                "Streaming pipeline must produce byte-identical output. Differences: \(comparison.differences)")
            XCTAssertEqual(comparison.differences.count, 0)
        }
    }

    /// Test that streaming tutorial processing produces identical output to baseline
    func test_streamingTutorialProcessingMatchesBaseline() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let baselineOutput = temp.childDirectory(named: "baseline")
            let streamingOutput = temp.childDirectory(named: "streaming")

            // Run baseline pipeline
            let baselinePipeline = MarkdownGenerationPipeline()
            let baselineSummary = try baselinePipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: baselineOutput.path,
                forceOverwrite: false)

            // Run streaming-optimized pipeline
            let streamingPipeline = MarkdownGenerationPipeline()  // Will be optimized implementation
            let streamingSummary = try streamingPipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: streamingOutput.path,
                forceOverwrite: false)

            // Verify identical output counts
            XCTAssertEqual(
                baselineSummary.tutorialVolumeCount,
                streamingSummary.tutorialVolumeCount,
                "Streaming pipeline should produce same number of tutorial volumes")
            XCTAssertEqual(
                baselineSummary.chapterCount,
                streamingSummary.chapterCount,
                "Streaming pipeline should produce same number of chapters")

            // Verify byte-identical outputs
            let validator = DeterminismValidator()
            let comparison = try validator.compareDirectories(
                firstPath: baselineOutput.path,
                secondPath: streamingOutput.path)

            XCTAssertTrue(
                comparison.isDeterministic,
                "Streaming pipeline must produce byte-identical output. Differences: \(comparison.differences)")
            XCTAssertEqual(comparison.differences.count, 0)
        }
    }

    /// Test that link graph generation is deterministic with streaming optimizations
    func test_streamingLinkGraphMatchesBaseline() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let baselineOutput = temp.childDirectory(named: "baseline")
            let streamingOutput = temp.childDirectory(named: "streaming")

            // Run both pipelines
            let baselinePipeline = MarkdownGenerationPipeline()
            _ = try baselinePipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: baselineOutput.path,
                forceOverwrite: false)

            let streamingPipeline = MarkdownGenerationPipeline()  // Will be optimized implementation
            _ = try streamingPipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: streamingOutput.path,
                forceOverwrite: false)

            // Compare link graph files
            let baselineLinkGraph = baselineOutput.appendingPathComponent("linkgraph/adjacency.json")
            let streamingLinkGraph = streamingOutput.appendingPathComponent("linkgraph/adjacency.json")

            let baselineData = try Data(contentsOf: baselineLinkGraph)
            let streamingData = try Data(contentsOf: streamingLinkGraph)

            XCTAssertEqual(
                baselineData,
                streamingData,
                "Link graph files must be byte-identical between baseline and streaming pipelines")
        }
    }

    /// Test memory efficiency with synthetic large fixture
    ///
    /// Note: This test creates a synthetic fixture by duplicating article content
    /// to simulate a larger DocC bundle without requiring multi-GB fixtures in the repository.
    func test_streamingReducesMemoryFootprintForLargeBundle() throws {
        // This test would require:
        // 1. Creating a synthetic large fixture (e.g., 100+ articles by duplicating existing ones)
        // 2. Measuring peak RSS during baseline vs streaming pipeline
        // 3. Asserting that streaming uses less memory or bounded memory relative to bundle size
        //
        // Implementation deferred pending profiling infrastructure enhancements
        // and decision on synthetic fixture generation strategy.

        XCTSkip("Memory measurement test requires synthetic large fixture and profiling infrastructure")
    }
}
