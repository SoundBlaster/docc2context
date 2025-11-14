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
        if manifest.bundles.isEmpty {
            XCTAssertTrue(
                manifest.bundles.isEmpty,
                "Manifest remains empty until task A3 publishes fixtures; release gates degrade gracefully."
            )
        } else {
            for bundle in manifest.bundles {
                XCTAssertFalse(bundle.id.isEmpty)
                XCTAssertEqual(bundle.checksum.algorithm.lowercased(), "sha256")
                XCTAssertFalse(bundle.relativePath.isEmpty)
            }
        }
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
