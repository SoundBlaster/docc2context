import XCTest
@testable import Docc2contextCore

final class Docc2contextCommandTests: XCTestCase {
    func testHelpFlagReturnsUsage() throws {
        let result = Docc2contextCommand().run(arguments: ["docc2context", "--help"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.output.contains("Usage:"))
        XCTAssertTrue(result.output.contains("docc2context"))
    }

    func testCLIErrorDescriptionsCoverAllCases() throws {
        XCTAssertTrue(Docc2contextCommand.CLIError.missingValue(flag: "--output").description.contains("requires a value"))
        XCTAssertTrue(Docc2contextCommand.CLIError.unknownFlag("--nope").description.contains("Unknown flag"))
        XCTAssertTrue(Docc2contextCommand.CLIError.unexpectedArgument("extra").description.contains("Unexpected argument"))
    }

    func testDefaultInvocationRemindsUserAboutInputRequirement() throws {
        let result = Docc2contextCommand().run(arguments: ["docc2context"])
        XCTAssertEqual(result.exitCode, 64)
        XCTAssertTrue(result.output.lowercased().contains("input"))
    }

    func testMissingOptionValueProducesUsageErrorViaValidationError() throws {
        let result = Docc2contextCommand().run(arguments: ["docc2context", "--output"])
        XCTAssertEqual(result.exitCode, 64)
        XCTAssertFalse(result.output.isEmpty)
    }

    func testSuccessfulInvocationSummarizesMarkdownGeneration() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "cmd-output")
            let result = Docc2contextCommand().run(arguments: [
                "docc2context",
                fixturesURL.path,
                "--output",
                outputDirectory.path
            ])

            XCTAssertEqual(result.exitCode, 0)
            XCTAssertTrue(result.output.contains("tutorial volume"))
            XCTAssertTrue(result.output.contains(outputDirectory.path))

            let expectedVolume = outputDirectory
                .appendingPathComponent("markdown", isDirectory: true)
                .appendingPathComponent("tutorials", isDirectory: true)
                .appendingPathComponent("tutorialcatalog", isDirectory: true)
                .appendingPathComponent("index.md", isDirectory: false)

            XCTAssertTrue(FileManager.default.fileExists(atPath: expectedVolume.path))
        }
    }

    func testUnexpectedErrorsFallBackToStringDescription() throws {
        struct PlainError: Error {}

        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let pipeline = MarkdownGenerationPipeline(
            markdownWriter: { _, _ in throw PlainError() },
            dataWriter: { _, _ in throw PlainError() }
        )

        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let outputDirectory = temp.childDirectory(named: "cmd-output-fallback")
            let result = Docc2contextCommand(pipeline: pipeline).run(arguments: [
                "docc2context",
                fixturesURL.path,
                "--output",
                outputDirectory.path,
            ])

            XCTAssertEqual(result.exitCode, 64)
            XCTAssertTrue(result.output.contains("PlainError"))
        }
    }
}
