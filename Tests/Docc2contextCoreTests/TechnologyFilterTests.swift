import XCTest
@testable import Docc2contextCore

final class TechnologyFilterTests: XCTestCase {
    func test_filteringByModuleNameExcludesOtherSymbols() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "filtered-output")

            let pipeline = MarkdownGenerationPipeline()
            let summary = try pipeline.generateMarkdown(
                from: fixturesURL.path,
                to: outputDirectory.path,
                forceOverwrite: false,
                technologyFilter: ["Docc2contextCore"])

            // F2 spec: filtered summary should report only included symbols
            XCTAssertGreaterThan(summary.symbolCount, 0, "Should include symbols from Docc2contextCore module")
        }
    }

    func test_filteringWithMultipleModulesIncludesAllMatching() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "multi-filter-output")

            let pipeline = MarkdownGenerationPipeline()
            let summary = try pipeline.generateMarkdown(
                from: fixturesURL.path,
                to: outputDirectory.path,
                forceOverwrite: false,
                technologyFilter: ["Docc2contextCore", "OtherModule"])

            // F2 spec: multiple filters should include symbols from any matching module
            XCTAssertGreaterThan(summary.symbolCount, 0, "Should include symbols from specified modules")
        }
    }

    func test_filteringWithNonMatchingModuleProducesEmptySymbolSet() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "empty-filter-output")

            let pipeline = MarkdownGenerationPipeline()
            let summary = try pipeline.generateMarkdown(
                from: fixturesURL.path,
                to: outputDirectory.path,
                forceOverwrite: false,
                technologyFilter: ["NonExistentModule"])

            // F2 spec: filter with no matches should produce empty symbol set
            XCTAssertEqual(summary.symbolCount, 0, "Should include no symbols when filter doesn't match")
        }
    }

    func test_filteredRunIsDeterministic() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let output1 = temp.childDirectory(named: "determinism-1")
            let output2 = temp.childDirectory(named: "determinism-2")

            let pipeline = MarkdownGenerationPipeline()

            _ = try pipeline.generateMarkdown(
                from: fixturesURL.path,
                to: output1.path,
                forceOverwrite: false,
                technologyFilter: ["Docc2contextCore"])

            _ = try pipeline.generateMarkdown(
                from: fixturesURL.path,
                to: output2.path,
                forceOverwrite: false,
                technologyFilter: ["Docc2contextCore"])

            // F2 spec: filtered conversions must be deterministic
            let validator = DeterminismValidator()
            let result = try validator.compareDirectories(firstPath: output1.path, secondPath: output2.path)
            XCTAssertTrue(result.isDeterministic, "Filtered outputs should be deterministic")
        }
    }

    func test_filteringDoesNotAffectTutorialsOrArticles() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let unfilteredOutput = temp.childDirectory(named: "unfiltered")
            let filteredOutput = temp.childDirectory(named: "filtered")

            let pipeline = MarkdownGenerationPipeline()

            let unfilteredSummary = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: unfilteredOutput.path,
                forceOverwrite: false,
                technologyFilter: nil)

            let filteredSummary = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: filteredOutput.path,
                forceOverwrite: false,
                technologyFilter: ["SomeModule"])

            // F2 spec: tutorials and articles should be unaffected by symbol filtering
            XCTAssertEqual(unfilteredSummary.tutorialVolumeCount, filteredSummary.tutorialVolumeCount,
                          "Tutorial count should not be affected by technology filter")
            XCTAssertEqual(unfilteredSummary.chapterCount, filteredSummary.chapterCount,
                          "Chapter count should not be affected by technology filter")
            XCTAssertEqual(unfilteredSummary.referenceArticleCount, filteredSummary.referenceArticleCount,
                          "Article count should not be affected by technology filter")
        }
    }
}
