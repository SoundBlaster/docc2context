import XCTest
@testable import Docc2contextCore

final class Docc2contextCoreDoccFixtureTests: XCTestCase {
    func test_generatedDoccFixtureCanBeConvertedToMarkdown() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "Docc2contextCore.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "output")
            let pipeline = MarkdownGenerationPipeline()

            let summary = try pipeline.generateMarkdown(
                from: fixtureURL.path,
                to: outputDirectory.path,
                forceOverwrite: false)

            XCTAssertGreaterThan(summary.symbolCount, 0, "Generated docs should include public symbols")

            let markdownRoot = outputDirectory.appendingPathComponent("markdown", isDirectory: true)
            XCTAssertTrue(FileManager.default.fileExists(atPath: markdownRoot.path))

            let linkGraph = outputDirectory
                .appendingPathComponent("linkgraph", isDirectory: true)
                .appendingPathComponent("adjacency.json", isDirectory: false)
            XCTAssertTrue(FileManager.default.fileExists(atPath: linkGraph.path))

            let fixtureDogfooding = markdownRoot
                .appendingPathComponent("articles", isDirectory: true)
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("docc2contextcore", isDirectory: true)
                .appendingPathComponent("fixturedogfooding.md", isDirectory: false)
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: fixtureDogfooding.path),
                "Expected Fixture dogfooding article to render to a stable path under articles/documentation/docc2contextcore/")

            let fixtureDogfoodingMarkdown = try String(contentsOf: fixtureDogfooding, encoding: .utf8)
            XCTAssertTrue(
                fixtureDogfoodingMarkdown.contains("Regenerating the fixture"),
                "Expected primary content sections (headings/paragraphs) to be rendered for the article")

            let equatableImplementations = markdownRoot
                .appendingPathComponent("articles", isDirectory: true)
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("docc2contextcore", isDirectory: true)
                .appendingPathComponent("markdowngenerationpipeline", isDirectory: true)
                .appendingPathComponent("summary", isDirectory: true)
                .appendingPathComponent("equatable-implementations.md", isDirectory: false)
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: equatableImplementations.path),
                "Expected collection-group pages to render to a stable path under articles/documentation/")

            let equatableMarkdown = try String(contentsOf: equatableImplementations, encoding: .utf8)
            XCTAssertTrue(equatableMarkdown.contains("## Topics"), "Expected collection-group topics to render")
            XCTAssertTrue(equatableMarkdown.contains("### Operators"), "Expected topic section headings to render")
            XCTAssertTrue(
                equatableMarkdown.contains("!=(_:_:)"),
                "Expected referenced symbols in topic sections to be discoverable in the Markdown output")

            let pipelineSymbol = markdownRoot
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("docc2contextcore", isDirectory: true)
                .appendingPathComponent("markdowngenerationpipeline", isDirectory: true)
                .appendingPathComponent("index.md", isDirectory: false)
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: pipelineSymbol.path),
                "Expected Swift-DocC symbol pages to render under markdown/documentation/")

            let pipelineSymbolMarkdown = try String(contentsOf: pipelineSymbol, encoding: .utf8)
            XCTAssertTrue(
                pipelineSymbolMarkdown.contains("Converts a DocC bundle into deterministic Markdown and a link graph."),
                "Expected symbol page summary to be rendered")
            XCTAssertTrue(pipelineSymbolMarkdown.contains("## Topics"), "Expected symbol Topics section to render")
            XCTAssertTrue(
                pipelineSymbolMarkdown.contains("MarkdownGenerationPipeline.Summary"),
                "Expected symbol Topics items to use reference titles")
            XCTAssertTrue(
                pipelineSymbolMarkdown.contains("generateMarkdown"),
                "Expected instance methods to appear in Topics")
            try MarkdownSnapshot.assertSnapshot(
                self,
                matching: pipelineSymbolMarkdown,
                named: "markdownGenerationPipelineSymbolPage",
                record: SnapshotRecording.isEnabled)

            let articlesRoot = markdownRoot.appendingPathComponent("articles", isDirectory: true)
            if FileManager.default.fileExists(atPath: articlesRoot.path) {
                let enumerator = FileManager.default.enumerator(at: articlesRoot, includingPropertiesForKeys: nil)
                let articles = (enumerator?.allObjects as? [URL] ?? [])
                    .filter { $0.pathExtension.lowercased() == "md" }
                XCTAssertFalse(articles.isEmpty, "Generated docs should include at least one article markdown file")
            } else {
                XCTFail("Expected generated docs to produce at least one article markdown file")
            }
        }
    }

    func test_generatedDoccFixtureProducesDeterministicOutputs() throws {
        let fixtureURL = FixtureLoader.urlForBundle(named: "Docc2contextCore.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDir1 = temp.childDirectory(named: "output1")
            let outputDir2 = temp.childDirectory(named: "output2")
            let pipeline = MarkdownGenerationPipeline()

            let summary1 = try pipeline.generateMarkdown(
                from: fixtureURL.path,
                to: outputDir1.path,
                forceOverwrite: false)
            let summary2 = try pipeline.generateMarkdown(
                from: fixtureURL.path,
                to: outputDir2.path,
                forceOverwrite: false)

            XCTAssertEqual(summary1.tutorialVolumeCount, summary2.tutorialVolumeCount)
            XCTAssertEqual(summary1.chapterCount, summary2.chapterCount)
            XCTAssertEqual(summary1.referenceArticleCount, summary2.referenceArticleCount)
            XCTAssertEqual(summary1.symbolCount, summary2.symbolCount)

            let validator = DeterminismValidator()
            let comparison = try validator.compareDirectories(
                firstPath: outputDir1.path,
                secondPath: outputDir2.path)
            XCTAssertTrue(comparison.isDeterministic, "Outputs should be byte-identical")
        }
    }
}
