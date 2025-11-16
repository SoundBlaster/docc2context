import XCTest
@testable import Docc2contextCore

final class DeterminismTests: XCTestCase {

    /// Test that consecutive runs produce identical Markdown files (determinism check)
    func test_consecutiveRunsProduceIdenticalMarkdownFiles() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDir1 = temp.childDirectory(named: "output1")
            let outputDir2 = temp.childDirectory(named: "output2")

            let pipeline = MarkdownGenerationPipeline()

            // First run
            let summary1 = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: outputDir1.path,
                forceOverwrite: false)

            // Second run to a different directory
            let summary2 = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: outputDir2.path,
                forceOverwrite: false)

            // Verify both runs produced same counts
            XCTAssertEqual(summary1.tutorialVolumeCount, summary2.tutorialVolumeCount)
            XCTAssertEqual(summary1.chapterCount, summary2.chapterCount)
            XCTAssertEqual(summary1.referenceArticleCount, summary2.referenceArticleCount)

            // Verify all Markdown files have identical content
            let validator = DeterminismValidator()
            let result = try validator.compareDirectories(
                firstPath: outputDir1.path,
                secondPath: outputDir2.path)

            XCTAssertTrue(result.isDeterministic,
                         "Directories should be byte-identical. Differences: \(result.differences)")
            XCTAssertEqual(result.differences.count, 0)
            XCTAssertEqual(result.hashesMatch, true)
        }
    }

    /// Test that link graph JSON is produced deterministically
    func test_linkGraphIsDeterministic() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDir1 = temp.childDirectory(named: "output1")
            let outputDir2 = temp.childDirectory(named: "output2")

            let pipeline = MarkdownGenerationPipeline()

            // First run
            _ = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: outputDir1.path,
                forceOverwrite: false)

            // Second run
            _ = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: outputDir2.path,
                forceOverwrite: false)

            // Verify link graph files match
            let validator = DeterminismValidator()
            let result = try validator.compareDirectories(
                firstPath: outputDir1.path,
                secondPath: outputDir2.path)

            XCTAssertTrue(result.isDeterministic,
                         "Link graphs should be byte-identical")

            // Specifically check link graph JSON files
            let linkGraphFile1 = outputDir1.appendingPathComponent("markdown/link-graph.json")
            let linkGraphFile2 = outputDir2.appendingPathComponent("markdown/link-graph.json")

            if FileManager.default.fileExists(atPath: linkGraphFile1.path) {
                let hash1 = try validator.hashFile(at: linkGraphFile1.path)
                let hash2 = try validator.hashFile(at: linkGraphFile2.path)
                XCTAssertEqual(hash1, hash2, "Link graph hashes should match")
            }
        }
    }

    /// Test that TOC and index files are deterministic
    func test_tocAndIndexAreDeterministic() throws {
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDir1 = temp.childDirectory(named: "output1")
            let outputDir2 = temp.childDirectory(named: "output2")

            let pipeline = MarkdownGenerationPipeline()

            // First run
            _ = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: outputDir1.path,
                forceOverwrite: false)

            // Second run
            _ = try pipeline.generateMarkdown(
                from: tutorialFixture.path,
                to: outputDir2.path,
                forceOverwrite: false)

            let validator = DeterminismValidator()

            // Check TOC file
            let tocFile1 = outputDir1.appendingPathComponent("markdown/TOC.md")
            let tocFile2 = outputDir2.appendingPathComponent("markdown/TOC.md")

            if FileManager.default.fileExists(atPath: tocFile1.path) {
                let hash1 = try validator.hashFile(at: tocFile1.path)
                let hash2 = try validator.hashFile(at: tocFile2.path)
                XCTAssertEqual(hash1, hash2, "TOC file hashes should match")
            }
        }
    }

    /// Test that determinism validator detects differences
    func test_determinismValidatorDetectsDifferences() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let dir1 = temp.url.appendingPathComponent("dir1", isDirectory: true)
            let dir2 = temp.url.appendingPathComponent("dir2", isDirectory: true)

            let fileManager = FileManager.default
            try fileManager.createDirectory(at: dir1, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: dir2, withIntermediateDirectories: true)

            // Create files with different content
            let file1Path = dir1.appendingPathComponent("test.md").path
            let file2Path = dir2.appendingPathComponent("test.md").path

            try "content".write(toFile: file1Path, atomically: true, encoding: .utf8)
            try "different content".write(toFile: file2Path, atomically: true, encoding: .utf8)

            let validator = DeterminismValidator()
            let result = try validator.compareDirectories(
                firstPath: dir1.path,
                secondPath: dir2.path)

            XCTAssertFalse(result.isDeterministic,
                          "Validator should detect different content")
            XCTAssertGreaterThan(result.differences.count, 0,
                                "Should report at least one difference")
        }
    }

    /// Test that determinism validator produces stable hashes for same content
    func test_hashingIsConsistent() throws {
        let testContent = "This is test content for hashing"

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let filePath = temp.url.appendingPathComponent("test.txt").path
            try testContent.write(toFile: filePath, atomically: true, encoding: .utf8)

            let validator = DeterminismValidator()
            let hash1 = try validator.hashFile(at: filePath)
            let hash2 = try validator.hashFile(at: filePath)

            XCTAssertEqual(hash1, hash2, "Same file should produce same hash")
            XCTAssertFalse(hash1.isEmpty, "Hash should not be empty")
        }
    }
}
