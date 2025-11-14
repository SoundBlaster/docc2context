import Foundation

public struct DoccBundleMetadata: Equatable {
    public let identifier: String
    public let displayName: String
    public let technologyRoot: String
    public let locales: [String]
    public let doccVersion: String?
    public let projectVersion: String?

    public init(identifier: String,
                displayName: String,
                technologyRoot: String,
                locales: [String],
                doccVersion: String?,
                projectVersion: String?) {
        self.identifier = identifier
        self.displayName = displayName
        self.technologyRoot = technologyRoot
        self.locales = locales
        self.doccVersion = doccVersion
        self.projectVersion = projectVersion
    }
}

public struct DoccRenderMetadata: Equatable, Decodable {
    public let formatVersion: String
    public let generatedAt: String
    public let generator: String
    public let kind: String
}

public struct DoccDocumentationCatalog: Equatable, Decodable {
    public struct AbstractItem: Equatable, Decodable {
        public let type: String
        public let text: String
    }

    public struct TopicSection: Equatable, Decodable {
        public let title: String
        public let identifiers: [String]
    }

    public let identifier: String
    public let kind: String
    public let title: String
    public let role: String?
    public let abstract: [AbstractItem]
    public let topics: [TopicSection]
}

public struct DoccSymbolReference: Equatable {
    public let identifier: String
    public let title: String
    public let moduleName: String
}

public enum DoccMetadataParserError: Error, LocalizedError, Equatable {
    case infoPlistMissing(URL)
    case invalidInfoPlist(URL)
    case missingRequiredField(String)
    case invalidFieldType(key: String, expected: String)
    case renderMetadataMissing(URL)
    case invalidRenderMetadata(URL)
    case documentationCatalogMissing(URL)
    case invalidDocumentationCatalog(URL)
    case invalidSymbolGraph(URL)

    public var errorDescription: String? {
        switch self {
        case let .infoPlistMissing(url):
            return "Info.plist not found at \(url.path)."
        case let .invalidInfoPlist(url):
            return "Info.plist at \(url.path) is not a valid property list."
        case let .missingRequiredField(field):
            return "Info.plist is missing required key '\(field)'."
        case let .invalidFieldType(key, expected):
            return "Info.plist key '\(key)' does not match expected type \(expected)."
        case let .renderMetadataMissing(url):
            return "Render metadata missing at \(url.path)."
        case let .invalidRenderMetadata(url):
            return "Render metadata at \(url.path) is not valid JSON."
        case let .documentationCatalogMissing(url):
            return "Documentation catalog missing at \(url.path)."
        case let .invalidDocumentationCatalog(url):
            return "Documentation catalog at \(url.path) is not valid JSON."
        case let .invalidSymbolGraph(url):
            return "Symbol graph at \(url.path) is malformed."
        }
    }
}

public struct DoccMetadataParser {
    public init() {}

    public func loadInfoPlist(from bundleURL: URL) throws -> DoccBundleMetadata {
        let infoPlistURL = bundleURL.appendingPathComponent("Info.plist", isDirectory: false)
        let plistData: Data

        do {
            plistData = try Data(contentsOf: infoPlistURL)
        } catch {
            throw DoccMetadataParserError.infoPlistMissing(infoPlistURL)
        }

        let plistObject: Any
        do {
            plistObject = try PropertyListSerialization.propertyList(from: plistData,
                                                                     options: [],
                                                                     format: nil)
        } catch {
            throw DoccMetadataParserError.invalidInfoPlist(infoPlistURL)
        }

        guard let plist = plistObject as? [String: Any] else {
            throw DoccMetadataParserError.invalidInfoPlist(infoPlistURL)
        }

        let identifier = try value(forKey: "Identifier", in: plist)
        let displayName = try value(forKey: "CFBundleName", in: plist)
        let technologyRoot = try value(forKey: "TechnologyRoot", in: plist)
        let locales = try languageArray(from: plist)
        let doccVersion = try optionalValue(forKey: "DocCVersion", in: plist)
        let projectVersion = try optionalValue(forKey: "ProjectVersion", in: plist)

        return DoccBundleMetadata(identifier: identifier,
                                  displayName: displayName,
                                  technologyRoot: technologyRoot,
                                  locales: locales,
                                  doccVersion: doccVersion,
                                  projectVersion: projectVersion)
    }

    public func loadRenderMetadata(from bundleURL: URL) throws -> DoccRenderMetadata {
        let metadataURL = bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("metadata", isDirectory: true)
            .appendingPathComponent("metadata.json", isDirectory: false)

        let data: Data
        do {
            data = try Data(contentsOf: metadataURL)
        } catch {
            throw DoccMetadataParserError.renderMetadataMissing(metadataURL)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(DoccRenderMetadata.self, from: data)
        } catch {
            throw DoccMetadataParserError.invalidRenderMetadata(metadataURL)
        }
    }

    public func loadDocumentationCatalog(from bundleURL: URL,
                                          technologyRoot: String) throws -> DoccDocumentationCatalog {
        let documentationURL = bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("documentation", isDirectory: true)
            .appendingPathComponent("\(technologyRoot).json", isDirectory: false)

        let data: Data
        do {
            data = try Data(contentsOf: documentationURL)
        } catch {
            throw DoccMetadataParserError.documentationCatalogMissing(documentationURL)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(DoccDocumentationCatalog.self, from: data)
        } catch {
            throw DoccMetadataParserError.invalidDocumentationCatalog(documentationURL)
        }
    }

    public func loadSymbolGraphReferences(from bundleURL: URL) throws -> [DoccSymbolReference] {
        let symbolGraphsDirectory = bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("symbol-graphs", isDirectory: true)

        guard FileManager.default.fileExists(atPath: symbolGraphsDirectory.path) else {
            return []
        }

        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: symbolGraphsDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        var references: [DoccSymbolReference] = []
        for fileURL in fileURLs where fileURL.pathExtension == "json" {
            let data = try Data(contentsOf: fileURL)
            let symbolGraph: SymbolGraphFile
            do {
                symbolGraph = try JSONDecoder().decode(SymbolGraphFile.self, from: data)
            } catch {
                throw DoccMetadataParserError.invalidSymbolGraph(fileURL)
            }

            for symbol in symbolGraph.symbols {
                guard let identifier = symbol.identifier,
                      let title = symbol.names?.title,
                      !identifier.isEmpty,
                      !title.isEmpty else {
                    continue
                }
                let reference = DoccSymbolReference(identifier: identifier,
                                                    title: title,
                                                    moduleName: symbolGraph.module.name)
                references.append(reference)
            }
        }

        return references.sorted { lhs, rhs in
            if lhs.identifier == rhs.identifier {
                return lhs.moduleName < rhs.moduleName
            }
            return lhs.identifier < rhs.identifier
        }
    }

    private func value(forKey key: String, in plist: [String: Any]) throws -> String {
        guard let rawValue = plist[key] else {
            throw DoccMetadataParserError.missingRequiredField(key)
        }
        guard let stringValue = rawValue as? String, !stringValue.isEmpty else {
            throw DoccMetadataParserError.invalidFieldType(key: key, expected: "non-empty String")
        }
        return stringValue
    }

    private func optionalValue(forKey key: String, in plist: [String: Any]) throws -> String? {
        guard let rawValue = plist[key] else { return nil }
        guard let stringValue = rawValue as? String else {
            throw DoccMetadataParserError.invalidFieldType(key: key, expected: "String")
        }
        return stringValue
    }

    private func languageArray(from plist: [String: Any]) throws -> [String] {
        guard let rawValue = plist["Languages"] else {
            throw DoccMetadataParserError.missingRequiredField("Languages")
        }
        guard let languages = rawValue as? [String] else {
            throw DoccMetadataParserError.invalidFieldType(key: "Languages", expected: "[String]")
        }

        let trimmed = languages.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        if trimmed.contains(where: { $0.isEmpty }) {
            throw DoccMetadataParserError.invalidFieldType(key: "Languages", expected: "non-empty strings")
        }
        return trimmed
    }
}

// MARK: - Private helpers

private struct SymbolGraphFile: Decodable {
    struct Module: Decodable {
        let name: String
    }

    struct Symbol: Decodable {
        struct Names: Decodable {
            let title: String?
        }

        let identifier: String?
        let names: Names?
    }

    let module: Module
    let symbols: [Symbol]
}
