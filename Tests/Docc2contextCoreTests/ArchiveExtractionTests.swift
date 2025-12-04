import XCTest
@testable import Docc2contextCore

final class ArchiveExtractionTests: XCTestCase {
    private var temporaryDirectory: URL!
    private let fileManager = FileManager.default

    override func setUp() async throws {
        temporaryDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() async throws {
        if let temporaryDirectory, fileManager.fileExists(atPath: temporaryDirectory.path) {
            try? fileManager.removeItem(at: temporaryDirectory)
        }
    }

    func testExtractsDoccarchiveIntoDeterministicDirectory() throws {
        let archiveURL = makeDoccarchiveFixture()
        let extractor = ArchiveExtractor(fileManager: fileManager)

        let firstExtraction = try extractor.extractDoccArchive(from: archiveURL, workingDirectory: temporaryDirectory)
        let secondExtraction = try extractor.extractDoccArchive(from: archiveURL, workingDirectory: temporaryDirectory)

        XCTAssertEqual(firstExtraction, secondExtraction)
        let extractedFile = firstExtraction.appendingPathComponent("data.txt")
        XCTAssertTrue(fileManager.fileExists(atPath: extractedFile.path))
        XCTAssertEqual(try String(contentsOf: extractedFile, encoding: .utf8), "hello world")
    }

    func testCleansUpTemporaryDirectoryOnFailure() throws {
        let archiveURL = makeDoccarchiveFixture()
        let extractor = ArchiveExtractor(fileManager: fileManager)

        enum FixtureError: Error { case downstreamFailure }

        XCTAssertThrowsError(
            try extractor.extractDoccArchive(from: archiveURL, workingDirectory: temporaryDirectory) { _ in
                throw FixtureError.downstreamFailure
            }
        )

        let destination = extractor.destinationDirectory(for: archiveURL, workingDirectory: temporaryDirectory)
        XCTAssertFalse(fileManager.fileExists(atPath: destination.path))
    }

    func testSurfacesCorruptedArchiveErrors() throws {
        let badArchive = temporaryDirectory.appendingPathComponent("broken.doccarchive", isDirectory: false)
        try Data("not a directory".utf8).write(to: badArchive)

        let extractor = ArchiveExtractor(fileManager: fileManager)

        XCTAssertThrowsError(try extractor.extractDoccArchive(from: badArchive, workingDirectory: temporaryDirectory)) { error in
            guard case ArchiveExtractionError.corruptedArchive(let url) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(url.lastPathComponent, "broken.doccarchive")
        }
    }

    // MARK: - Helpers

    private func makeDoccarchiveFixture() -> URL {
        let archiveURL = temporaryDirectory.appendingPathComponent("Sample.doccarchive", isDirectory: true)
        let fileURL = archiveURL.appendingPathComponent("data.txt", isDirectory: false)
        try! fileManager.createDirectory(at: archiveURL, withIntermediateDirectories: true)
        try! "hello world".write(to: fileURL, atomically: true, encoding: .utf8)
        return archiveURL
    }
}
