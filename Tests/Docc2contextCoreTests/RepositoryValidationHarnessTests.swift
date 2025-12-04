import XCTest
@testable import Docc2contextCore

final class RepositoryValidationHarnessTests: XCTestCase {
    func testRepositoryMetadataFixturesValidateSuccessfully() throws {
        let fixturesDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
        let harness = RepositoryValidationHarness()
        let expectation = RepositoryValidationExpectation.fixturesDefault()

        let result = try harness.validate(fixturesDirectory: fixturesDirectory, expectation: expectation)

        XCTAssertTrue(result.isValid, "Expected fixtures to validate cleanly, got issues: \(result.issues)")
        XCTAssertEqual(result.issues, [])
    }

    func testTamperedAptPackagesHashIsReported() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let fileManager = FileManager.default
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata")
            try fileManager.copyItem(at: sourceDirectory, to: workingDirectory)

            let packagesFile = workingDirectory
                .appendingPathComponent("apt", isDirectory: true)
                .appendingPathComponent("Packages", isDirectory: false)
            try "corrupted".data(using: .utf8)!.write(to: packagesFile)

            let harness = RepositoryValidationHarness(fileManager: fileManager)
            let expectation = RepositoryValidationExpectation.fixturesDefault()
            let result = try harness.validate(fixturesDirectory: workingDirectory, expectation: expectation)

            XCTAssertFalse(result.isValid)
            XCTAssertTrue(
                result.issues.contains(where: { $0.message.contains("Packages hash mismatch") }),
                "Expected hash mismatch issue for Packages, got: \(result.issues)"
            )
        }
    }

    func testExpectationMismatchIsReported() throws {
        let fixturesDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
        let harness = RepositoryValidationHarness()
        var expectation = RepositoryValidationExpectation.fixturesDefault()
        expectation.apt.version = "0.1.0"

        let result = try harness.validate(fixturesDirectory: fixturesDirectory, expectation: expectation)

        XCTAssertFalse(result.isValid)
        XCTAssertTrue(
            result.issues.contains(where: { $0.message.contains("Version") && $0.message.contains("0.1.0") }),
            "Expected version mismatch issue, got: \(result.issues)"
        )
    }
}
