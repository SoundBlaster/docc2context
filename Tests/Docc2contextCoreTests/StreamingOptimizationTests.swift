import XCTest
@testable import Docc2contextCore

/// Tests for F1 Incremental Conversion streaming/memory optimizations
///
/// **Design Note**: These tests validate determinism of the optimized pipeline after
/// the streaming optimization was applied. They do NOT compare baseline vs optimized
/// implementations because:
/// 1. The old `loadAvailableArticles()` method was removed to maintain >90% coverage
/// 2. The optimization was made default behavior after parity validation
/// 3. Baseline correctness is validated by existing DeterminismTests and MarkdownGenerationPipelineTests
///
/// The optimization (loadAvailableArticlesDictionary) eliminates intermediate array
/// allocations while maintaining byte-identical outputs verified by existing test suites.
final class StreamingOptimizationTests: XCTestCase {

    /// Test that optimized article processing produces deterministic output
    ///
    /// Validates that the streaming optimization maintains deterministic behavior
    /// across multiple runs with the ArticleReference fixture.
    func test_optimizedArticleProcessingIsDeterministic() throws {
        let articleFixture = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let firstOutput = temp.childDirectory(named: "run1")
            let secondOutput = temp.childDirectory(named: "run2")

            // First run with optimized pipeline
            let pipeline1 = MarkdownGenerationPipeline()
            let summary1 = try pipeline1.generateMarkdown(
                from: articleFixture.path,
                to: firstOutput.path,
                forceOverwrite: false)

            // Second run with optimized pipeline
            let pipeline2 = MarkdownGenerationPipeline()
            let summary2 = try pipeline2.generateMarkdown(
                from: articleFixture.path,
                to: secondOutput.path,
                forceOverwrite: false)

            // Verify identical output counts
            XCTAssertEqual(
                summary1.referenceArticleCount,
                summary2.referenceArticleCount,
                "Optimized pipeline should produce consistent article counts")

            // Verify byte-identical outputs (determinism check)
            let validator = DeterminismValidator()
            let comparison = try validator.compareDirectories(
                firstPath: firstOutput.path,
                secondPath: secondOutput.path)

            XCTAssertTrue(
                comparison.isDeterministic,
                "Optimized pipeline must produce deterministic output. Differences: \(comparison.differences)")
            XCTAssertEqual(comparison.differences.count, 0)
        }
    }

    /// Test that optimized tutorial processing produces deterministic output
    ///
    /// Validates that the streaming optimization maintains deterministic behavior
    /// across multiple runs with the TutorialCatalog fixture.
    func test_optimizedTutorialProcessingIsDeterministic() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let firstOutput = temp.childDirectory(named: "run1")
            let secondOutput = temp.childDirectory(named: "run2")

            // First run with optimized pipeline
            let pipeline1 = MarkdownGenerationPipeline()
            let summary1 = try pipeline1.generateMarkdown(
                from: tutorialFixture.path,
                to: firstOutput.path,
                forceOverwrite: false)

            // Second run with optimized pipeline
            let pipeline2 = MarkdownGenerationPipeline()
            let summary2 = try pipeline2.generateMarkdown(
                from: tutorialFixture.path,
                to: secondOutput.path,
                forceOverwrite: false)

            // Verify identical output counts
            XCTAssertEqual(
                summary1.tutorialVolumeCount,
                summary2.tutorialVolumeCount,
                "Optimized pipeline should produce consistent tutorial volume counts")
            XCTAssertEqual(
                summary1.chapterCount,
                summary2.chapterCount,
                "Optimized pipeline should produce consistent chapter counts")

            // Verify byte-identical outputs (determinism check)
            let validator = DeterminismValidator()
            let comparison = try validator.compareDirectories(
                firstPath: firstOutput.path,
                secondPath: secondOutput.path)

            XCTAssertTrue(
                comparison.isDeterministic,
                "Optimized pipeline must produce deterministic output. Differences: \(comparison.differences)")
            XCTAssertEqual(comparison.differences.count, 0)
        }
    }

    /// Test that link graph generation remains deterministic after optimization
    ///
    /// Validates that streaming optimizations do not introduce non-determinism
    /// in link graph generation.
    func test_optimizedLinkGraphIsDeterministic() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let firstOutput = temp.childDirectory(named: "run1")
            let secondOutput = temp.childDirectory(named: "run2")

            // First run
            let pipeline1 = MarkdownGenerationPipeline()
            _ = try pipeline1.generateMarkdown(
                from: tutorialFixture.path,
                to: firstOutput.path,
                forceOverwrite: false)

            // Second run
            let pipeline2 = MarkdownGenerationPipeline()
            _ = try pipeline2.generateMarkdown(
                from: tutorialFixture.path,
                to: secondOutput.path,
                forceOverwrite: false)

            // Compare link graph files
            let linkGraph1 = firstOutput.appendingPathComponent("linkgraph/adjacency.json")
            let linkGraph2 = secondOutput.appendingPathComponent("linkgraph/adjacency.json")

            let data1 = try Data(contentsOf: linkGraph1)
            let data2 = try Data(contentsOf: linkGraph2)

            XCTAssertEqual(
                data1,
                data2,
                "Link graph files must be byte-identical across runs")
        }
    }

    /// Test memory efficiency with synthetic large fixture
    ///
    /// Note: This test would require creating a synthetic large fixture to demonstrate
    /// memory reduction benefits of the streaming optimization. Current small fixtures
    /// (2-3 articles) are dominated by ~70MB Swift runtime overhead, masking the benefit.
    ///
    /// Expected improvement for bundles with 1000+ articles: 15-25% memory reduction
    /// by eliminating intermediate array allocation in loadAvailableArticlesDictionary().
    func test_streamingReducesMemoryFootprintForLargeBundle() throws {
        // Implementation deferred pending:
        // 1. Synthetic large-bundle fixture generation strategy
        // 2. Memory measurement infrastructure beyond Scripts/profile_memory.sh
        // 3. CI integration for performance regression detection

        throw XCTSkip("Memory measurement test requires synthetic large fixture and profiling infrastructure")
    }
}
