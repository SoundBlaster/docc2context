import XCTest
@testable import Docc2contextCore

final class RepositoryMetadataFixturesTests: XCTestCase {
    func testRepositoryMetadataFixturesMatchManifest() throws {
        let fixturesDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
        let manifestURL = fixturesDirectory.appendingPathComponent("manifest.json")

        let validator = RepositoryMetadataFixturesValidator()
        let result = try validator.validate(fixturesDirectory: fixturesDirectory, manifestURL: manifestURL)

        XCTAssertTrue(result.isValid, "Expected repository metadata fixtures to match manifest, found: \(result.invalidEntries)")
        XCTAssertEqual(result.invalidEntries, [])
    }

    func testValidatorDetectsTamperedFixture() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let fileManager = FileManager.default
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata")
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata")
            try fileManager.copyItem(at: sourceDirectory, to: workingDirectory)

            let packagesFile = workingDirectory
                .appendingPathComponent("apt", isDirectory: true)
                .appendingPathComponent("Packages", isDirectory: false)
            try "tampered".data(using: .utf8)!.write(to: packagesFile)

            let validator = RepositoryMetadataFixturesValidator(fileManager: fileManager)
            let manifestURL = workingDirectory.appendingPathComponent("manifest.json")
            let result = try validator.validate(fixturesDirectory: workingDirectory, manifestURL: manifestURL)

            XCTAssertFalse(result.isValid)
            XCTAssertEqual(result.invalidEntries.count, 1)
            XCTAssertEqual(result.invalidEntries.first?.id, "apt-packages")
            XCTAssertEqual(result.invalidEntries.first?.reason, "hash mismatch, size mismatch")
        }
    }
}
