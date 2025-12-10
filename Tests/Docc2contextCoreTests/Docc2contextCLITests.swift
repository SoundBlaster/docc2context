import XCTest
@testable import Docc2contextCore

final class Docc2contextCLITests: XCTestCase {
    func testMissingInputPathTriggersUsageError() throws {
        let command = Docc2contextCommand()
        let result = command.run(arguments: ["docc2context", "--output", "/tmp/out"])

        XCTAssertEqual(result.exitCode, 64, "B1 spec: invocations without an input path should exit with usage error once argument parsing lands.")
        XCTAssertTrue(result.output.lowercased().contains("input"), "B1 spec: error text should mention the missing input path.")
    }

    func testMissingOutputOptionIsRejected() throws {
        let command = Docc2contextCommand()
        let result = command.run(arguments: ["docc2context", "/tmp/MyDocs.doccarchive"])

        XCTAssertEqual(result.exitCode, 64, "B1 spec: output directory must be explicitly provided via --output.")
        XCTAssertTrue(result.output.contains("--output"), "B1 spec: error message should instruct users to pass --output.")
    }

    func testFormatOptionValidatesSupportedValues() throws {
        let command = Docc2contextCommand()
        let result = command.run(arguments: [
            "docc2context",
            "/tmp/MyDocs.doccarchive",
            "--output",
            "/tmp/out",
            "--format",
            "html"
        ])

        XCTAssertEqual(result.exitCode, 64, "B1 spec: unsupported --format values should emit allowed formats in the error message.")
        XCTAssertTrue(result.output.lowercased().contains("markdown"), "B1 spec: error text should remind users that markdown is the supported value.")
    }

    func testHelpDescribesOutputForceAndFormatFlags() throws {
        let result = Docc2contextCommand().run(arguments: ["docc2context", "--help"])

        XCTAssertTrue(result.output.contains("--output"), "B1 spec: help text must document --output flag.")
        XCTAssertTrue(result.output.contains("--force"), "B1 spec: help text must document --force flag.")
        XCTAssertTrue(result.output.contains("--format"), "B1 spec: help text must document --format flag.")
    }

    func testForceFlagAllowsOverwritingExistingOutputDirectory() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "cli-output")
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

            let command = Docc2contextCommand()
            let result = command.run(arguments: [
                "docc2context",
                fixturesURL.path,
                "--output",
                outputDirectory.path,
                "--force"
            ])

            XCTAssertEqual(result.exitCode, 0)
            XCTAssertTrue(result.output.contains("tutorial volume"))

            let tutorialIndex = outputDirectory
                .appendingPathComponent("markdown", isDirectory: true)
                .appendingPathComponent("tutorials", isDirectory: true)
                .appendingPathComponent("tutorialcatalog", isDirectory: true)
                .appendingPathComponent("index.md", isDirectory: false)

            XCTAssertTrue(FileManager.default.fileExists(atPath: tutorialIndex.path))
        }
    }

    func testExistingOutputWithoutForceReturnsUsageError() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "cli-existing")
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

            let command = Docc2contextCommand()
            let result = command.run(arguments: [
                "docc2context",
                fixturesURL.path,
                "--output",
                outputDirectory.path
            ])

            XCTAssertEqual(result.exitCode, 64)
            XCTAssertTrue(result.output.contains("--force"))
        }
    }

    func testInputThatIsNotDirectorySurfacesPipelineError() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let bogusFile = temp.url.appendingPathComponent("not-a-directory.md")
            try "markdown".write(to: bogusFile, atomically: true, encoding: .utf8)
            let outputDirectory = temp.childDirectory(named: "cli-output")

            let command = Docc2contextCommand()
            let result = command.run(arguments: [
                "docc2context",
                bogusFile.path,
                "--output",
                outputDirectory.path,
                "--force"
            ])

            XCTAssertEqual(result.exitCode, 64)
            XCTAssertTrue(result.output.contains("directory"),
                          "Pipeline error description should mention directory requirement")
        }
    }

    func testArchiveInputProvidesExtractionGuidance() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let archiveFile = temp.url.appendingPathComponent("Bundle.doccarchive")
            try Data("archive".utf8).write(to: archiveFile)
            let outputDirectory = temp.childDirectory(named: "cli-archive-output")

            let command = Docc2contextCommand()
            let result = command.run(arguments: [
                "docc2context",
                archiveFile.path,
                "--output",
                outputDirectory.path,
                "--force"
            ])

            XCTAssertEqual(result.exitCode, 64)
            XCTAssertTrue(
                result.output.contains("archive file; extract it before converting"),
                "Detection error should mention archive inputs requiring extraction"
            )
        }
    }

    func testFilterTechnologyFlagIsRecognized() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "cli-filtered")

            let command = Docc2contextCommand()
            let result = command.run(arguments: [
                "docc2context",
                fixturesURL.path,
                "--output",
                outputDirectory.path,
                "--force",
                "--technology", "Docc2contextCore"
            ])

            XCTAssertEqual(result.exitCode, 0, "F2 spec: --technology flag should be accepted")
        }
    }

    func testFilterTechnologyFlagCanBeRepeated() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "cli-multi-filter")

            let command = Docc2contextCommand()
            let result = command.run(arguments: [
                "docc2context",
                fixturesURL.path,
                "--output",
                outputDirectory.path,
                "--force",
                "--technology", "ModuleA",
                "--technology", "ModuleB"
            ])

            XCTAssertEqual(result.exitCode, 0, "F2 spec: --technology flag should accept multiple modules")
        }
    }

    func testHelpDescribesFilterTechnologyFlag() throws {
        let result = Docc2contextCommand().run(arguments: ["docc2context", "--help"])

        XCTAssertTrue(result.output.contains("--technology"), "F2 spec: help text must document --technology flag.")
        XCTAssertTrue(result.output.contains("technology"), "F2 spec: help text must document technology filter option.")
    }
}
