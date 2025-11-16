import XCTest
@testable import Docc2contextCore

final class MarkdownGenerationPipelineTests: XCTestCase {
    func test_pipelineWritesTutorialVolumesAndChapters() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "output")
            let pipeline = MarkdownGenerationPipeline()
            let summary = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: outputDirectory.path,
                forceOverwrite: false)

            XCTAssertEqual(summary.tutorialVolumeCount, 1)
            XCTAssertEqual(summary.chapterCount, 1)
            XCTAssertEqual(summary.referenceArticleCount, 0)

            let volumeURL = outputDirectory
                .appendingPathComponent("markdown", isDirectory: true)
                .appendingPathComponent("tutorials", isDirectory: true)
                .appendingPathComponent("tutorialcatalog", isDirectory: true)
                .appendingPathComponent("index.md", isDirectory: false)

            let chapterURL = volumeURL.deletingLastPathComponent()
                .appendingPathComponent("getting-started.md", isDirectory: false)

            let volumeMarkdown = try String(contentsOf: volumeURL, encoding: .utf8)
            let chapterMarkdown = try String(contentsOf: chapterURL, encoding: .utf8)

            try MarkdownSnapshot.assertSnapshot(
                self,
                matching: volumeMarkdown,
                named: "tutorialVolumeOverviewFromPipeline",
                record: SnapshotRecording.isEnabled)

            try MarkdownSnapshot.assertSnapshot(
                self,
                matching: chapterMarkdown,
                named: "tutorialChapterFromPipeline",
                record: SnapshotRecording.isEnabled)
        }
    }

    func test_pipelineWritesReferenceArticles() throws {
        let articleFixture = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "articles-output")
            let pipeline = MarkdownGenerationPipeline()
            let summary = try pipeline.generateMarkdown(
                from: articleFixture.path,
                to: outputDirectory.path,
                forceOverwrite: false)

            XCTAssertEqual(summary.tutorialVolumeCount, 0)
            XCTAssertEqual(summary.chapterCount, 0)
            XCTAssertEqual(summary.referenceArticleCount, 2)

            let articleURL = outputDirectory
                .appendingPathComponent("markdown", isDirectory: true)
                .appendingPathComponent("articles", isDirectory: true)
                .appendingPathComponent("articlereference", isDirectory: true)
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("articles", isDirectory: true)
                .appendingPathComponent("api-walkthrough.md", isDirectory: false)

            let articleMarkdown = try String(contentsOf: articleURL, encoding: .utf8)
            try MarkdownSnapshot.assertSnapshot(
                self,
                matching: articleMarkdown,
                named: "referenceArticleFromPipeline",
                record: SnapshotRecording.isEnabled)
        }
    }

    func test_pipelineRejectsExistingOutputWithoutForce() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "existing")
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

            let pipeline = MarkdownGenerationPipeline()
            XCTAssertThrowsError(
                try pipeline.generateMarkdown(
                    from: tutorialFixture.path,
                    to: outputDirectory.path,
                    forceOverwrite: false)) { error in
                guard let pipelineError = error as? MarkdownGenerationPipeline.Error else {
                    XCTFail("Expected MarkdownGenerationPipeline.Error but received \(error)")
                    return
                }
                switch pipelineError {
                case .outputDirectoryAlreadyExists(let url):
                    XCTAssertEqual(url.path, outputDirectory.path)
                default:
                    XCTFail("Unexpected error: \(pipelineError)")
                }
            }
        }
    }
}
