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

    func testDnfPrimaryHashMismatchIsReported() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let fileManager = FileManager.default
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata")
            try fileManager.copyItem(at: sourceDirectory, to: workingDirectory)

            let primaryXML = workingDirectory
                .appendingPathComponent("dnf", isDirectory: true)
                .appendingPathComponent("repodata", isDirectory: true)
                .appendingPathComponent("primary.xml", isDirectory: false)

            var contents = try String(contentsOf: primaryXML, encoding: .utf8)
            contents.append("\n<!-- tampered to change checksum -->\n")
            try contents.write(to: primaryXML, atomically: true, encoding: .utf8)

            let harness = RepositoryValidationHarness(fileManager: fileManager)
            let expectation = RepositoryValidationExpectation.fixturesDefault()
            let result = try harness.validate(fixturesDirectory: workingDirectory, expectation: expectation)

            XCTAssertFalse(result.isValid)
            XCTAssertTrue(
                result.issues.contains(where: { $0.message.contains("repodata/primary.xml hash mismatch") }),
                "Expected primary checksum mismatch issue, got: \(result.issues)"
            )
        }
    }

    func testDnfPrimaryLocationMismatchIsReported() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let fileManager = FileManager.default
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata")
            try fileManager.copyItem(at: sourceDirectory, to: workingDirectory)

            let repomdXML = workingDirectory
                .appendingPathComponent("dnf", isDirectory: true)
                .appendingPathComponent("repodata", isDirectory: true)
                .appendingPathComponent("repomd.xml", isDirectory: false)

            let contents = try String(contentsOf: repomdXML, encoding: .utf8)
            let modified = contents.replacingOccurrences(of: "repodata/primary.xml", with: "repodata/primary-alt.xml")
            try modified.write(to: repomdXML, atomically: true, encoding: .utf8)

            let harness = RepositoryValidationHarness(fileManager: fileManager)
            let expectation = RepositoryValidationExpectation.fixturesDefault()
            let result = try harness.validate(fixturesDirectory: workingDirectory, expectation: expectation)

            XCTAssertFalse(result.isValid)
            XCTAssertTrue(
                result.issues.contains(where: { $0.message.contains("Unexpected primary location") }),
                "Expected primary location mismatch issue, got: \(result.issues)"
            )
        }
    }

    func testInvalidPackageHashIsReportedAsNonHexDigest() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let fileManager = FileManager.default
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata")
            try fileManager.copyItem(at: sourceDirectory, to: workingDirectory)

            let packagesFile = workingDirectory
                .appendingPathComponent("apt", isDirectory: true)
                .appendingPathComponent("Packages", isDirectory: false)

            let contents = try String(contentsOf: packagesFile, encoding: .utf8)
            let modified = contents.replacingOccurrences(of: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", with: "not-a-hex")
            try modified.write(to: packagesFile, atomically: true, encoding: .utf8)

            let harness = RepositoryValidationHarness(fileManager: fileManager)
            let expectation = RepositoryValidationExpectation.fixturesDefault()
            let result = try harness.validate(fixturesDirectory: workingDirectory, expectation: expectation)

            XCTAssertFalse(result.isValid)
            XCTAssertTrue(
                result.issues.contains(where: { $0.message.contains("SHA256 field is not a valid hex digest") }),
                "Expected invalid hex digest issue, got: \(result.issues)"
            )
        }
    }
}
