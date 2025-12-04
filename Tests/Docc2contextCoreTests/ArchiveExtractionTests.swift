import XCTest
@testable import Docc2contextCore

/// Tests for PRD Phase B task B4 (archive extraction).
final class ArchiveExtractionTests: XCTestCase {
    func testExtractsDoccarchiveIntoDeterministicDirectory() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let sourceArchive = temp.childDirectory(named: "Sample.doccarchive")
            try FileManager.default.createDirectory(at: sourceArchive, withIntermediateDirectories: true)
            try "hello".write(to: sourceArchive.appendingPathComponent("index.json"), atomically: true, encoding: .utf8)

            let extractor = ArchiveExtractor()
            let first = try extractor.extract(at: sourceArchive.path)
            let second = try extractor.extract(at: sourceArchive.path)

            XCTAssertEqual(first.outputDirectory, second.outputDirectory, "Deterministic destination expected")
            XCTAssertTrue(FileManager.default.fileExists(atPath: first.outputDirectory.path))
            let copiedFile = first.outputDirectory.appendingPathComponent("index.json")
            XCTAssertEqual(try String(contentsOf: copiedFile, encoding: .utf8), "hello")

            try first.cleanup()
            XCTAssertFalse(FileManager.default.fileExists(atPath: first.outputDirectory.path))
        }
    }

    func testCleansUpTemporaryDirectoryOnFailure() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let corruptFile = temp.url.appendingPathComponent("Broken.doccarchive")
            try "stub".data(using: .utf8)?.write(to: corruptFile)

            let extractor = ArchiveExtractor()
            let destination = try extractor.deterministicDestination(for: corruptFile)

            XCTAssertThrowsError(try extractor.extract(at: corruptFile.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        }
    }

    func testSurfacesCorruptedArchiveErrors() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let corruptFile = temp.url.appendingPathComponent("Corrupt.doccarchive")
            try "not a directory".data(using: .utf8)?.write(to: corruptFile)

            let extractor = ArchiveExtractor()
            XCTAssertThrowsError(try extractor.extract(at: corruptFile.path)) { error in
                XCTAssertEqual(error as? ArchiveExtractionError, .corruptedArchive)
            }
        }
    }
}
