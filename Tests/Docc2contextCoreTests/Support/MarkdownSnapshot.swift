import Foundation
import XCTest

enum MarkdownSnapshot {
    enum SnapshotError: Error, LocalizedError {
        case referenceMissing(URL)

        var errorDescription: String? {
            switch self {
            case .referenceMissing(let url):
                return "Snapshot reference missing at \(url.path)."
            }
        }
    }

    static func assertSnapshot(
        _ testCase: XCTestCase,
        matching text: String,
        named snapshotName: String,
        record: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let normalized = normalize(text)
        let fileManager = FileManager.default
        let snapshotURL = url(for: testCase, named: snapshotName)
        let directory = snapshotURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        if record || !fileManager.fileExists(atPath: snapshotURL.path) {
            try normalized.write(to: snapshotURL, atomically: true, encoding: .utf8)
            if !record {
                throw SnapshotError.referenceMissing(snapshotURL)
            }
            return
        }

        let expected = try String(contentsOf: snapshotURL, encoding: .utf8)
        XCTAssertEqual(normalized, normalize(expected), "Snapshot mismatch for \(snapshotName)", file: file, line: line)
    }

    private static func normalize(_ text: String) -> String {
        var normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        if !normalized.hasSuffix("\n") {
            normalized.append("\n")
        }
        return normalized
    }

    private static func url(for testCase: XCTestCase, named snapshotName: String) -> URL {
        let className = String(describing: type(of: testCase))
        return TestSupportPaths.snapshotsDirectory
            .appendingPathComponent(className, isDirectory: true)
            .appendingPathComponent(snapshotName)
            .appendingPathExtension("md")
    }
}
