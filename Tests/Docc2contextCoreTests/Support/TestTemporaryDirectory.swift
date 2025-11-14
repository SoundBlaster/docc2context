import Foundation

/// Utility for creating deterministic temporary directories during XCTest runs.
/// Directories are automatically removed once the helper leaves scope, ensuring
/// deterministic behavior across repeated runs.
final class TestTemporaryDirectory {
    private let fileManager: FileManager
    let url: URL

    init(prefix: String = "docc2context-tests", fileManager: FileManager = .default) throws {
        self.fileManager = fileManager
        let base = fileManager.temporaryDirectory.appendingPathComponent(prefix, isDirectory: true)
        if !fileManager.fileExists(atPath: base.path) {
            try fileManager.createDirectory(at: base, withIntermediateDirectories: true)
        }
        let unique = base.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: unique, withIntermediateDirectories: true)
        self.url = unique
    }

    deinit {
        cleanup()
    }

    /// Creates a file inside the temporary directory with the provided data.
    @discardableResult
    func writeFile(named name: String, contents: Data = Data()) throws -> URL {
        let fileURL = url.appendingPathComponent(name)
        try contents.write(to: fileURL)
        return fileURL
    }

    /// Returns a child directory URL without creating it.
    func childDirectory(named name: String) -> URL {
        url.appendingPathComponent(name, isDirectory: true)
    }

    /// Removes the directory if it still exists.
    func cleanup() {
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        } catch {
            // Best-effort cleanup; leave breadcrumb for debugging if needed.
            if let data = "⚠️ Failed to remove temporary directory: \(error)\n".data(using: .utf8) {
                FileHandle.standardError.write(data)
            }
        }
    }

    /// Convenience helper that creates a scoped temporary directory, executes the
    /// closure, and then deletes the directory.
    static func withTemporaryDirectory<T>(
        prefix: String = "docc2context-tests",
        fileManager: FileManager = .default,
        _ body: (TestTemporaryDirectory) throws -> T
    ) throws -> T {
        let directory = try TestTemporaryDirectory(prefix: prefix, fileManager: fileManager)
        defer { directory.cleanup() }
        return try body(directory)
    }
}
