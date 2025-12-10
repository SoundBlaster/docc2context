import Foundation

public struct InputLocationDetector {
    public enum InputLocation: Equatable {
        case doccBundle(URL)
        case doccArchive(URL)
    }

    public enum DetectionError: Error, LocalizedError, Equatable {
        case inputDoesNotExist(URL)
        case inputIsNotDoccBundle(URL)
        case archiveInputRequiresExtraction(URL)

        public var errorDescription: String? {
            switch self {
            case .inputDoesNotExist(let url):
                return "Input path does not exist at \(url.path)"
            case .inputIsNotDoccBundle(let url):
                return "Input is not a valid DocC bundle or archive: \(url.path)"
            case .archiveInputRequiresExtraction(let url):
                return "Input is a DocC archive file; extract it before converting: \(url.path)"
            }
        }
    }

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func detect(inputPath: String) throws -> InputLocation {
        let url = URL(fileURLWithPath: inputPath).standardizedFileURL
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            throw DetectionError.inputDoesNotExist(url)
        }

        if isDirectory.boolValue {
            guard isDoccDirectory(url) else {
                throw DetectionError.inputIsNotDoccBundle(url)
            }
            return .doccBundle(url)
        }

        guard url.pathExtension.lowercased() == "doccarchive" else {
            throw DetectionError.inputIsNotDoccBundle(url)
        }

        return .doccArchive(url)
    }

    public func resolvedBundleURL(from location: InputLocation) throws -> URL {
        switch location {
        case .doccBundle(let url):
            return url
        case .doccArchive(let url):
            throw DetectionError.archiveInputRequiresExtraction(url)
        }
    }

    private func isDoccDirectory(_ url: URL) -> Bool {
        let acceptableExtensions = ["docc", "doccarchive"]
        if acceptableExtensions.contains(url.pathExtension.lowercased()) {
            return true
        }

        let infoPlist = url.appendingPathComponent("Info.plist", isDirectory: false)
        return fileManager.fileExists(atPath: infoPlist.path)
    }
}
