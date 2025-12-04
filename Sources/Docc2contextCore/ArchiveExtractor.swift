import Crypto
import Foundation

public enum ArchiveExtractionError: Error, Equatable, CustomStringConvertible {
    case missingArchive
    case corruptedArchive
    case unsupportedInput

    public var description: String {
        switch self {
        case .missingArchive:
            return "Archive could not be found at the provided path."
        case .corruptedArchive:
            return "Archive appears to be corrupted or unreadable."
        case .unsupportedInput:
            return "Only .doccarchive bundles are supported for extraction."
        }
    }
}

public struct ArchiveExtractionResult {
    public let outputDirectory: URL
    private let cleanupHandler: () throws -> Void

    public init(outputDirectory: URL, cleanupHandler: @escaping () throws -> Void) {
        self.outputDirectory = outputDirectory
        self.cleanupHandler = cleanupHandler
    }

    public func cleanup() throws {
        try cleanupHandler()
    }
}

public final class ArchiveExtractor {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func extract(at path: String) throws -> ArchiveExtractionResult {
        let sourceURL = URL(fileURLWithPath: path)
        var isDirectory: ObjCBool = false

        guard fileManager.fileExists(atPath: sourceURL.path, isDirectory: &isDirectory) else {
            throw ArchiveExtractionError.missingArchive
        }

        guard sourceURL.pathExtension == "doccarchive" else {
            throw ArchiveExtractionError.unsupportedInput
        }

        let destinationURL = try deterministicDestination(for: sourceURL)

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            if isDirectory.boolValue {
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
            } else {
                throw ArchiveExtractionError.corruptedArchive
            }
        } catch {
            try? fileManager.removeItem(at: destinationURL)
            throw error
        }

        return ArchiveExtractionResult(outputDirectory: destinationURL) {
            if self.fileManager.fileExists(atPath: destinationURL.path) {
                try self.fileManager.removeItem(at: destinationURL)
            }
        }
    }

    func deterministicDestination(for sourceURL: URL) throws -> URL {
        let hash = Insecure.SHA1.hash(data: sourceURL.path.data(using: .utf8) ?? Data())
            .map { String(format: "%02hhx", $0) }
            .joined()
        let directoryName = "docc2context-\(hash)"
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(directoryName, isDirectory: true)
        if !fileManager.fileExists(atPath: tempDir.deletingLastPathComponent().path) {
            try fileManager.createDirectory(at: tempDir.deletingLastPathComponent(), withIntermediateDirectories: true)
        }
        return tempDir
    }
}
