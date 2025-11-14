import XCTest

final class HarnessUtilitiesTests: XCTestCase {
    func testTemporaryDirectoryCreatesAndCleansUp() throws {
        var createdURL: URL?
        try TestTemporaryDirectory.withTemporaryDirectory { directory in
            createdURL = directory.url
            XCTAssertTrue(FileManager.default.fileExists(atPath: directory.url.path))
            _ = try directory.writeFile(named: "example.txt", contents: Data("hello".utf8))
            XCTAssertTrue(FileManager.default.fileExists(atPath: directory.url.appendingPathComponent("example.txt").path))
        }

        if let url = createdURL {
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        }
    }

    func testFixtureManifestLoadsFromDisk() throws {
        let manifest = try FixtureLoader.loadManifest()
        XCTAssertEqual(manifest.schemaVersion, 1)
        XCTAssertFalse(manifest.bundles.isEmpty, "Manifest should list at least one placeholder bundle during A3 bring-up.")
    }

    func testMarkdownSnapshotComparison() throws {
        let markdown = """
        # Snapshot Example
        
        Harness utilities provide deterministic output.
        """
        try MarkdownSnapshot.assertSnapshot(
            self,
            matching: markdown,
            named: "testMarkdownSnapshotComparison"
        )
    }
}
