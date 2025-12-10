import XCTest
@testable import Docc2contextCore

final class InputDetectionTests: XCTestCase {
    func testDetectsDoccarchiveDirectory() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let bundleURL = temporaryDirectory.url
                .appendingPathComponent("Sample.doccarchive", isDirectory: true)
                .standardizedFileURL
            try FileManager.default.createDirectory(at: bundleURL, withIntermediateDirectories: true)

            let detector = InputLocationDetector()
            let location = try detector.detect(inputPath: bundleURL.path)

            XCTAssertEqual(location, .doccBundle(bundleURL))
        }
    }

    func testRejectsNonDoccDirectory() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let invalidDirectory = temporaryDirectory.url
                .appendingPathComponent("NotADocC", isDirectory: true)
                .standardizedFileURL
            try FileManager.default.createDirectory(at: invalidDirectory, withIntermediateDirectories: true)

            let detector = InputLocationDetector()

            XCTAssertThrowsError(try detector.detect(inputPath: invalidDirectory.path)) { error in
                guard let detectionError = error as? InputLocationDetector.DetectionError else {
                    return XCTFail("Unexpected error type: \(error)")
                }
                XCTAssertEqual(detectionError, .inputIsNotDoccBundle(invalidDirectory))
                XCTAssertEqual(
                    detectionError.errorDescription,
                    "Input is not a valid DocC bundle or archive: \(invalidDirectory.path)"
                )
            }
        }
    }

    func testRejectsNonDoccArchiveFile() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let invalidFile = temporaryDirectory.url
                .appendingPathComponent("not-a-docc.txt", isDirectory: false)
                .standardizedFileURL
            try Data("content".utf8).write(to: invalidFile)

            let detector = InputLocationDetector()

            XCTAssertThrowsError(try detector.detect(inputPath: invalidFile.path)) { error in
                guard let detectionError = error as? InputLocationDetector.DetectionError else {
                    return XCTFail("Unexpected error type: \(error)")
                }
                XCTAssertEqual(detectionError, .inputIsNotDirectory(invalidFile))
                XCTAssertEqual(
                    detectionError.errorDescription,
                    "Input path must be a directory containing a DocC bundle: \(invalidFile.path)"
                )
            }
        }
    }

    func testDetectsDoccarchiveFile() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let archiveURL = temporaryDirectory.url
                .appendingPathComponent("Sample.doccarchive", isDirectory: false)
                .standardizedFileURL
            try Data("archive".utf8).write(to: archiveURL)

            let detector = InputLocationDetector()
            let location = try detector.detect(inputPath: archiveURL.path)

            XCTAssertEqual(location, .doccArchive(archiveURL))
        }
    }
}
