import XCTest
@testable import Docc2contextCore

final class MarkdownGenerationPipelineTests: XCTestCase {
    func test_pipelineRejectsMissingInputDirectory() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let missingInput = temp.childDirectory(named: "does-not-exist")
            let outputDirectory = temp.childDirectory(named: "output")
            let pipeline = MarkdownGenerationPipeline()

            XCTAssertThrowsError(
                try pipeline.generateMarkdown(
                    from: missingInput.path,
                    to: outputDirectory.path,
                    forceOverwrite: false)) { error in
                guard case let .inputDoesNotExist(url) = error as? MarkdownGenerationPipeline.Error else {
                    XCTFail("Expected missing input error but received \(error)")
                    return
                }
                XCTAssertEqual(url.path, missingInput.path)
            }
        }
    }

    func test_pipelineRejectsFileInput() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let bogusFile = temp.url.appendingPathComponent("not-a-directory.json")
            try "data".write(to: bogusFile, atomically: true, encoding: .utf8)
            let outputDirectory = temp.childDirectory(named: "output")

            let pipeline = MarkdownGenerationPipeline()

            XCTAssertThrowsError(
                try pipeline.generateMarkdown(
                    from: bogusFile.path,
                    to: outputDirectory.path,
                    forceOverwrite: false)) { error in
                guard case let .inputIsNotDirectory(url) = error as? MarkdownGenerationPipeline.Error else {
                    XCTFail("Expected inputIsNotDirectory error but received \(error)")
                    return
                }
                XCTAssertEqual(url.path, bogusFile.path)
            }
        }
    }

    func test_pipelineSurfacesOutputCreationFailures() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "output")
            let fileManager = AlwaysFailingCreateFileManager()
            let pipeline = MarkdownGenerationPipeline(fileManager: fileManager)

            XCTAssertThrowsError(
                try pipeline.generateMarkdown(
                    from: tutorialFixture.path,
                    to: outputDirectory.path,
                    forceOverwrite: false)) { error in
                guard case let .failedToCreateOutput(url, underlying) = error as? MarkdownGenerationPipeline.Error else {
                    XCTFail("Expected failedToCreateOutput but received \(error)")
                    return
                }
                XCTAssertEqual(url.path, outputDirectory.path)
                XCTAssertTrue(underlying is AlwaysFailingCreateFileManager.StubError)
            }
        }
    }

    func test_pipelineSurfacesRemovalFailures() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "output")
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

            let fileManager = RemovalFailingFileManager()
            let pipeline = MarkdownGenerationPipeline(fileManager: fileManager)

            XCTAssertThrowsError(
                try pipeline.generateMarkdown(
                    from: tutorialFixture.path,
                    to: outputDirectory.path,
                    forceOverwrite: true)) { error in
                guard case let .failedToRemoveExistingOutput(url, underlying) = error as? MarkdownGenerationPipeline.Error else {
                    XCTFail("Expected failedToRemoveExistingOutput but received \(error)")
                    return
                }
                XCTAssertEqual(url.path, outputDirectory.path)
                XCTAssertTrue(underlying is RemovalFailingFileManager.StubError)
            }
        }
    }

    func test_pipelineSurfacesMarkdownWriteFailures() throws {
        enum WriterError: Swift.Error { case expected }
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "output")
            let pipeline = MarkdownGenerationPipeline(
                markdownWriter: { _, _ in throw WriterError.expected })

            XCTAssertThrowsError(
                try pipeline.generateMarkdown(
                    from: tutorialFixture.path,
                    to: outputDirectory.path,
                    forceOverwrite: false)) { error in
                guard case let .failedToWriteFile(_, underlying) = error as? MarkdownGenerationPipeline.Error else {
                    XCTFail("Expected failedToWriteFile but received \(error)")
                    return
                }
                XCTAssertTrue(underlying is WriterError)
            }
        }
    }

    func test_pipelineSurfacesDataWriteFailures() throws {
        enum WriterError: Swift.Error { case expected }
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "output")
            let pipeline = MarkdownGenerationPipeline(
                dataWriter: { _, _ in throw WriterError.expected })

            XCTAssertThrowsError(
                try pipeline.generateMarkdown(
                    from: tutorialFixture.path,
                    to: outputDirectory.path,
                    forceOverwrite: false)) { error in
                guard case let .failedToWriteFile(_, underlying) = error as? MarkdownGenerationPipeline.Error else {
                    XCTFail("Expected failedToWriteFile but received \(error)")
                    return
                }
                XCTAssertTrue(underlying is WriterError)
            }
        }
    }

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

            let volumeDirectory = outputDirectory
                .appendingPathComponent("markdown", isDirectory: true)
                .appendingPathComponent("tutorials", isDirectory: true)
                .appendingPathComponent("tutorialcatalog", isDirectory: true)

            let volumeURL = volumeDirectory.appendingPathComponent("index.md", isDirectory: false)
            let chapterURL = pipeline.makeChapterFileURL(
                title: "Getting Started",
                index: 0,
                under: volumeDirectory)

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

    func test_chapterFileURLDisambiguatesDuplicateTitles() {
        let pipeline = MarkdownGenerationPipeline()
        let volumeDirectory = URL(fileURLWithPath: "/tmp/tutorials/volume", isDirectory: true)

        let firstChapterURL = pipeline.makeChapterFileURL(
            title: "Orientation",
            index: 0,
            under: volumeDirectory)

        let secondChapterURL = pipeline.makeChapterFileURL(
            title: "Orientation",
            index: 1,
            under: volumeDirectory)

        XCTAssertNotEqual(firstChapterURL, secondChapterURL)
        XCTAssertTrue(firstChapterURL.lastPathComponent.hasPrefix("1-orientation"))
        XCTAssertTrue(secondChapterURL.lastPathComponent.hasPrefix("2-orientation"))
    }

    func test_pipelineWritesLinkGraph() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "output")
            let pipeline = MarkdownGenerationPipeline()
            _ = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: outputDirectory.path,
                forceOverwrite: false)

            // Verify link graph file exists
            let linkGraphURL = outputDirectory
                .appendingPathComponent("linkgraph", isDirectory: true)
                .appendingPathComponent("adjacency.json", isDirectory: false)

            XCTAssertTrue(FileManager.default.fileExists(atPath: linkGraphURL.path),
                         "Link graph JSON file should be written to output")

            // Verify link graph is valid JSON
            let data = try Data(contentsOf: linkGraphURL)
            let decoder = JSONDecoder()
            let linkGraph = try decoder.decode(LinkGraph.self, from: data)

            // Verify link graph has expected structure
            XCTAssertFalse(linkGraph.allPageIdentifiers.isEmpty,
                          "Link graph should contain page identifiers")
        }
    }
}

private final class AlwaysFailingCreateFileManager: FileManager, @unchecked Sendable {
    enum StubError: Swift.Error { case createDirectory }

    override func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey : Any]? = nil
    ) throws {
        throw StubError.createDirectory
    }

    override func removeItem(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}

private final class RemovalFailingFileManager: FileManager, @unchecked Sendable {
    enum StubError: Swift.Error { case removal }

    override func removeItem(at url: URL) throws {
        throw StubError.removal
    }

    override func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey : Any]? = nil
    ) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes)
    }
}
