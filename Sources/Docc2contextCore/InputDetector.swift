import Foundation

public enum DetectedDoccInput: Equatable {
    case doccArchiveDirectory(URL)
    case doccArchiveFile(URL)
    case unsupported
}

public struct InputDetector {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func detect(at path: String) -> DetectedDoccInput {
        let url = URL(fileURLWithPath: path)
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return .unsupported
        }

        if isDirectory.boolValue {
            if url.pathExtension == "doccarchive" || url.pathExtension == "docc" {
                return .doccArchiveDirectory(url)
            }
            return .unsupported
        }

        if url.pathExtension == "doccarchive" {
            return .doccArchiveFile(url)
        }

        return .unsupported
    }
}
