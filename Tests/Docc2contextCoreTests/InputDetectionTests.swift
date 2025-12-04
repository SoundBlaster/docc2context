import XCTest
@testable import Docc2contextCore

/// Tests for PRD Phase B task B3 (input detection).
final class InputDetectionTests: XCTestCase {
    func testDetectsDoccarchiveDirectory() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let bundleDir = temp.childDirectory(named: "Sample.doccarchive")
            try FileManager.default.createDirectory(at: bundleDir, withIntermediateDirectories: true)

            let detector = InputDetector()
            let result = detector.detect(at: bundleDir.path)

            switch result {
            case .doccArchiveDirectory(let url):
                XCTAssertEqual(url.lastPathComponent, "Sample.doccarchive")
            default:
                XCTFail("Expected directory detection for .doccarchive bundle")
            }
        }
    }

    func testRejectsNonDoccDirectory() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let nonDoccDir = temp.childDirectory(named: "Notes")
            try FileManager.default.createDirectory(at: nonDoccDir, withIntermediateDirectories: true)

            let detector = InputDetector()
            let result = detector.detect(at: nonDoccDir.path)

            XCTAssertEqual(result, .unsupported)
        }
    }

    func testDetectsDoccarchiveFile() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            let archiveFile = temp.url.appendingPathComponent("Packed.doccarchive")
            try "stub".data(using: .utf8)?.write(to: archiveFile)

            let detector = InputDetector()
            let result = detector.detect(at: archiveFile.path)

            XCTAssertEqual(result, .doccArchiveFile(archiveFile))
        }
    }
}
