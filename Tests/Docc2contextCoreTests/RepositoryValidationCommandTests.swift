import XCTest
@testable import Docc2contextCore

final class RepositoryValidationCommandTests: XCTestCase {
    func testCommandPassesWithFixtureDefaults() throws {
        let fixturesRoot = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata", isDirectory: true)
        let result = RepositoryValidationCommand().run(arguments: [
            "repository-validation",
            "--fixtures-path", fixturesRoot.path
        ])

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.output.contains("0.0.0-test"))
        XCTAssertTrue(result.output.contains("Validation succeeded"))
    }

    func testCommandFailsWhenExpectedVersionDoesNotMatch() throws {
        let fixturesRoot = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata", isDirectory: true)
        let result = RepositoryValidationCommand().run(arguments: [
            "repository-validation",
            "--fixtures-path", fixturesRoot.path,
            "--expected-version", "9.9.9"
        ])

        XCTAssertNotEqual(result.exitCode, 0)
        XCTAssertTrue(result.output.lowercased().contains("version expected"))
    }

    func testCommandIgnoresExtraArguments() throws {
        let fixturesRoot = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata", isDirectory: true)
        let result = RepositoryValidationCommand().run(arguments: [
            "repository-validation",
            "--fixtures-path", fixturesRoot.path,
            "--unexpected-flag", "value",
            "positional-extra"
        ])

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.output.contains("Validation succeeded"))
        XCTAssertTrue(result.output.contains("Ignored unexpected arguments"))
        XCTAssertTrue(result.output.contains("--unexpected-flag value positional-extra"))
    }
}
