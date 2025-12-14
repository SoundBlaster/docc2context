import XCTest
@testable import Docc2contextCore

final class RepositoryMetadataFixturesValidatorAdditionalTests: XCTestCase {
    func testValidatorReportsMissingFixture() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            // Write a manifest that references a non-existent file.
            let manifestURL = temporaryDirectory.url.appendingPathComponent("manifest.json")
            let manifestJSON = """
            {
              "_schema": 1,
              "fixtures": [
                {
                  "id": "missing",
                  "relative_path": "does/not/exist",
                  "sha256": "\(String(repeating: "0", count: 64))",
                  "size_bytes": 123
                }
              ]
            }
            """
            try manifestJSON.data(using: .utf8)!.write(to: manifestURL)

            let validator = RepositoryMetadataFixturesValidator()
            let result = try validator.validate(
                fixturesDirectory: temporaryDirectory.url,
                manifestURL: manifestURL)

            XCTAssertFalse(result.isValid)
            XCTAssertEqual(result.invalidEntries.count, 1)
            let entry = try XCTUnwrap(result.invalidEntries.first)
            XCTAssertEqual(entry.id, "missing")
            XCTAssertEqual(entry.reason, "missing file")
            XCTAssertNil(entry.actualSHA256)
            XCTAssertNil(entry.actualSize)
        }
    }
}
