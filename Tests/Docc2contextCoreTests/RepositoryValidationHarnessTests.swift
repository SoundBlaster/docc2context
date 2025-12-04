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

    func testMissingReleaseFieldsAreReported() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let fileManager = FileManager.default
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata")
            try fileManager.copyItem(at: sourceDirectory, to: workingDirectory)

            let releaseURL = workingDirectory
                .appendingPathComponent("apt", isDirectory: true)
                .appendingPathComponent("Release", isDirectory: false)
            let strippedRelease = try String(contentsOf: releaseURL, encoding: .utf8)
                .components(separatedBy: "\n")
                .filter { line in
                    !line.hasPrefix("Architectures:") &&
                    !line.hasPrefix("Components:") &&
                    !line.contains("Packages")
                }
                .joined(separator: "\n")
            try strippedRelease.write(to: releaseURL, atomically: true, encoding: .utf8)

            let harness = RepositoryValidationHarness(fileManager: fileManager)
            let expectation = RepositoryValidationExpectation.fixturesDefault()
            let result = try harness.validate(fixturesDirectory: workingDirectory, expectation: expectation)

            XCTAssertFalse(result.isValid)
            XCTAssertTrue(result.issues.contains { $0.message.contains("Missing Architectures field") })
            XCTAssertTrue(result.issues.contains { $0.message.contains("Missing Components field") })
            XCTAssertTrue(result.issues.contains { $0.message.contains("Missing Packages hash entry") })
        }
    }

    func testInvalidAptPackageDigestIsReported() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let fileManager = FileManager.default
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata")
            try fileManager.copyItem(at: sourceDirectory, to: workingDirectory)

            let packagesURL = workingDirectory
                .appendingPathComponent("apt", isDirectory: true)
                .appendingPathComponent("Packages", isDirectory: false)
            let corruptedPackages = try String(contentsOf: packagesURL, encoding: .utf8)
                .replacingOccurrences(of: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", with: "not-a-hex-digest")
            try corruptedPackages.write(to: packagesURL, atomically: true, encoding: .utf8)

            let harness = RepositoryValidationHarness(fileManager: fileManager)
            let expectation = RepositoryValidationExpectation.fixturesDefault()
            let result = try harness.validate(fixturesDirectory: workingDirectory, expectation: expectation)

            XCTAssertFalse(result.isValid)
            XCTAssertTrue(result.issues.contains { $0.message.contains("SHA256 field mismatch") })
            XCTAssertTrue(result.issues.contains { $0.message.contains("SHA256 field is not a valid hex digest") })
        }
    }

    func testMissingPrimaryChecksumEntryReported() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let fileManager = FileManager.default
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata")
            try fileManager.copyItem(at: sourceDirectory, to: workingDirectory)

            let repomdURL = workingDirectory
                .appendingPathComponent("dnf", isDirectory: true)
                .appendingPathComponent("repodata", isDirectory: true)
                .appendingPathComponent("repomd.xml", isDirectory: false)
            let repomdWithoutChecksum = try String(contentsOf: repomdURL, encoding: .utf8)
                .components(separatedBy: "\n")
                .filter { !$0.contains("checksum") }
                .joined(separator: "\n")
            try repomdWithoutChecksum.write(to: repomdURL, atomically: true, encoding: .utf8)

            let harness = RepositoryValidationHarness(fileManager: fileManager)
            let expectation = RepositoryValidationExpectation.fixturesDefault()
            let result = try harness.validate(fixturesDirectory: workingDirectory, expectation: expectation)

            XCTAssertFalse(result.isValid)
            XCTAssertTrue(result.issues.contains { $0.message.contains("Missing primary checksum entry") })
        }
    }

    func testMalformedPrimaryXMLThrowsParseError() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let fileManager = FileManager.default
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata")
            try fileManager.copyItem(at: sourceDirectory, to: workingDirectory)

            let primaryURL = workingDirectory
                .appendingPathComponent("dnf", isDirectory: true)
                .appendingPathComponent("repodata", isDirectory: true)
                .appendingPathComponent("primary.xml", isDirectory: false)
            try "not xml".write(to: primaryURL, atomically: true, encoding: .utf8)

            let harness = RepositoryValidationHarness(fileManager: fileManager)
            let expectation = RepositoryValidationExpectation.fixturesDefault()

            XCTAssertThrowsError(try harness.validate(fixturesDirectory: workingDirectory, expectation: expectation))
        }
    }
}
