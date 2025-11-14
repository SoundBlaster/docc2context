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
}
