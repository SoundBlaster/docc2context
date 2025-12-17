import XCTest
@testable import Docc2contextCore

final class DeterministicJSONEncoderTests: XCTestCase {
    private struct Sample: Codable, Equatable {
        let url: String
        let name: String
        let createdAt: Date
    }

    func testEncoderUsesSortedKeysAndUnescapedSlashes() throws {
        let sample = Sample(
            url: "https://example.com/foo/bar",
            name: "zeta",
            createdAt: ISO8601DateFormatter().date(from: "2024-01-02T03:04:05Z")!)

        let encoder = DeterministicJSONEncoder.makeEncoder()
        let data = try encoder.encode(sample)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        // Keys should be sorted and slashes should not be escaped.
        XCTAssertTrue(json.contains("\"createdAt\""))
        XCTAssertTrue(json.contains("\"name\""))
        XCTAssertTrue(json.contains("\"url\""))
        XCTAssertFalse(json.contains("\\/"))
        XCTAssertTrue(json.contains("https://example.com/foo/bar"))
        XCTAssertTrue(json.contains("2024-01-02T03:04:05Z"))
    }
}
