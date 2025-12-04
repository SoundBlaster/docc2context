import Crypto
import Foundation

public enum ArchiveExtractionError: Error, Equatable, LocalizedError {
    case missingSource(URL)
    case unsupportedArchive(URL)
    case corruptedArchive(URL)
    case copyFailed(URL)

    public var errorDescription: String? {
        switch self {
        case .missingSource(let url):
            return "Archive missing at \(url.path)."
        case .unsupportedArchive(let url):
            return "Unsupported archive format for \(url.lastPathComponent). Provide a .doccarchive directory."
        case .corruptedArchive(let url):
            return "Archive at \(url.lastPathComponent) appears to be corrupted."
        case .copyFailed(let url):
            return "Failed to extract archive to \(url.path)."
        }
    }
}

public struct ArchiveExtractor {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func extractDoccArchive(
        from sourceURL: URL,
        workingDirectory: URL,
        postprocess: ((URL) throws -> Void)? = nil
    ) throws -> URL {
        guard fileManager.fileExists(atPath: sourceURL.path) else {
            throw ArchiveExtractionError.missingSource(sourceURL)
        }

        guard sourceURL.pathExtension == "doccarchive" else {
            throw ArchiveExtractionError.unsupportedArchive(sourceURL)
        }

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: sourceURL.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw ArchiveExtractionError.corruptedArchive(sourceURL)
        }

        let destination = destinationDirectory(for: sourceURL, workingDirectory: workingDirectory)

        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)

        do {
            try fileManager.copyItem(at: sourceURL, to: destination)
        } catch {
            throw ArchiveExtractionError.copyFailed(destination)
        }

        do {
            if let postprocess {
                try postprocess(destination)
            }
            return destination
        } catch {
            try? fileManager.removeItem(at: destination)
            throw error
        }
    }

    func destinationDirectory(for sourceURL: URL, workingDirectory: URL) -> URL {
        let deterministicFolderName = makeDeterministicFolderName(for: sourceURL)
        return workingDirectory.appendingPathComponent(deterministicFolderName, isDirectory: true)
    }

    private func makeDeterministicFolderName(for sourceURL: URL) -> String {
        let normalizedPath = sourceURL.standardizedFileURL.path
        let digest = SHA256.hash(data: Data(normalizedPath.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return "doccarchive-\(hex.prefix(12))"
    }
}
