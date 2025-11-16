import Foundation

public struct DoccBundleMetadata: Equatable, Codable {
    public let identifier: String
    public let displayName: String
    public let technologyRoot: String
    public let locales: [String]
    public let doccVersion: String?
    public let projectVersion: String?

    public init(
        identifier: String,
        displayName: String,
        technologyRoot: String,
        locales: [String],
        doccVersion: String?,
        projectVersion: String?
    ) {
        self.identifier = identifier
        self.displayName = displayName
        self.technologyRoot = technologyRoot
        self.locales = locales
        self.doccVersion = doccVersion
        self.projectVersion = projectVersion
    }
}

public struct DoccRenderMetadata: Equatable, Codable {
    public let formatVersion: String
    public let generatedAt: String
    public let generator: String
    public let kind: String

    public init(
        formatVersion: String,
        generatedAt: String,
        generator: String,
        kind: String
    ) {
        self.formatVersion = formatVersion
        self.generatedAt = generatedAt
        self.generator = generator
        self.kind = kind
    }
}

public struct DoccDocumentationCatalog: Equatable, Codable {
    public struct AbstractItem: Equatable, Codable {
        public let type: String
        public let text: String

        public init(type: String, text: String) {
            self.type = type
            self.text = text
        }
    }

    public struct TopicSection: Equatable, Codable {
        public let title: String
        public let identifiers: [String]

        public init(title: String, identifiers: [String]) {
            self.title = title
            self.identifiers = identifiers
        }
    }

    public let identifier: String
    public let kind: String
    public let title: String
    public let role: String?
    public let abstract: [AbstractItem]
    public let topics: [TopicSection]
}

public struct DoccArticle: Equatable, Codable {
    public struct AbstractItem: Equatable, Codable {
        public let type: String
        public let text: String

        public init(type: String, text: String) {
            self.type = type
            self.text = text
        }
    }

    public struct Section: Equatable, Codable {
        public let title: String
        public let content: [String]

        public init(title: String, content: [String]) {
            self.title = title
            self.content = content
        }
    }

    public struct TopicSection: Equatable, Codable {
        public let title: String
        public let identifiers: [String]

        public init(title: String, identifiers: [String]) {
            self.title = title
            self.identifiers = identifiers
        }
    }

    public struct Reference: Equatable, Codable {
        public let identifier: String
        public let kind: String
        public let title: String

        public init(identifier: String, kind: String, title: String) {
            self.identifier = identifier
            self.kind = kind
            self.title = title
        }
    }

    public let identifier: String
    public let kind: String
    public let title: String
    public let abstract: [AbstractItem]
    public let sections: [Section]
    public let topics: [TopicSection]
    public let references: [Reference]

    public init(
        identifier: String,
        kind: String,
        title: String,
        abstract: [AbstractItem],
        sections: [Section],
        topics: [TopicSection],
        references: [Reference]
    ) {
        self.identifier = identifier
        self.kind = kind
        self.title = title
        self.abstract = abstract
        self.sections = sections
        self.topics = topics
        self.references = references
    }

    private enum CodingKeys: String, CodingKey {
        case identifier
        case kind
        case title
        case abstract
        case sections
        case topics
        case references
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        kind = try container.decode(String.self, forKey: .kind)
        title = try container.decode(String.self, forKey: .title)
        abstract = try container.decodeIfPresent([AbstractItem].self, forKey: .abstract) ?? []
        sections = try container.decodeIfPresent([Section].self, forKey: .sections) ?? []
        topics = try container.decodeIfPresent([TopicSection].self, forKey: .topics) ?? []
        references = try container.decodeIfPresent([Reference].self, forKey: .references) ?? []
    }
}

public struct DoccTutorial: Equatable, Codable {
    public struct Step: Equatable, Codable {
        public let title: String
        public let content: [String]
    }

    public struct Assessment: Equatable, Codable {
        public let title: String
        public let items: [AssessmentItem]
    }

    public struct AssessmentItem: Equatable, Codable {
        public let prompt: String
        public let choices: [String]
        public let answer: Int
    }

    public let identifier: String
    public let title: String
    public let introduction: String?
    public let steps: [Step]
    public let assessments: [Assessment]
}

public struct DoccSymbolReference: Equatable, Codable {
    public let identifier: String
    public let title: String
    public let moduleName: String

    public init(
        identifier: String,
        title: String,
        moduleName: String
    ) {
        self.identifier = identifier
        self.title = title
        self.moduleName = moduleName
    }
}

public struct DoccBundleDataMetadata: Equatable, Codable {
    public let formatVersion: String
    public let generatedAt: Date
    public let generator: String
    public let kind: String

    public init(formatVersion: String, generatedAt: Date, generator: String, kind: String) {
        self.formatVersion = formatVersion
        self.generatedAt = generatedAt
        self.generator = generator
        self.kind = kind
    }
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
    case metadataJSONMissing(URL)
    case invalidMetadataJSON(URL)
    case tutorialPageMissing(URL)
    case invalidTutorialPage(URL)
    case articlePageMissing(URL)
    case invalidArticlePage(URL)

    public var errorDescription: String? {
        switch self {
        case .infoPlistMissing(let url):
            return "Info.plist not found at \(url.path)."
        case .invalidInfoPlist(let url):
            return "Info.plist at \(url.path) is not a valid property list."
        case .missingRequiredField(let field):
            return "Info.plist is missing required key '\(field)'."
        case .invalidFieldType(let key, let expected):
            return "Info.plist key '\(key)' does not match expected type \(expected)."
        case .renderMetadataMissing(let url):
            return "Render metadata missing at \(url.path)."
        case .invalidRenderMetadata(let url):
            return "Render metadata at \(url.path) is not valid JSON."
        case .documentationCatalogMissing(let url):
            return "Documentation catalog missing at \(url.path)."
        case .invalidDocumentationCatalog(let url):
            return "Documentation catalog at \(url.path) is not valid JSON."
        case .invalidSymbolGraph(let url):
            return "Symbol graph at \(url.path) is malformed."
        case .metadataJSONMissing(let url):
            return "metadata.json not found at \(url.path)."
        case .invalidMetadataJSON(let url):
            return "metadata.json at \(url.path) is not valid JSON."
        case .tutorialPageMissing(let url):
            return "Tutorial page not found at \(url.path)."
        case .invalidTutorialPage(let url):
            return "Tutorial page at \(url.path) is not valid JSON."
        case .articlePageMissing(let url):
            return "Article page not found at \(url.path)."
        case .invalidArticlePage(let url):
            return "Article page at \(url.path) is not valid JSON."
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
            plistObject = try PropertyListSerialization.propertyList(
                from: plistData,
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

        return DoccBundleMetadata(
            identifier: identifier,
            displayName: displayName,
            technologyRoot: technologyRoot,
            locales: locales,
            doccVersion: doccVersion,
            projectVersion: projectVersion)
    }

    public func loadRenderMetadata(from bundleURL: URL) throws -> DoccRenderMetadata {
        let metadataURL =
            bundleURL
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

    public func loadDocumentationCatalog(
        from bundleURL: URL,
        technologyRoot: String
    ) throws -> DoccDocumentationCatalog {
        let documentationURL =
            bundleURL
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
        let symbolGraphsDirectory =
            bundleURL
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
        for fileURL in fileURLs
        where fileURL.lastPathComponent.lowercased().hasSuffix(".symbols.json") {
            let data = try Data(contentsOf: fileURL)
            let symbolGraph: SymbolGraphFile
            do {
                symbolGraph = try JSONDecoder().decode(SymbolGraphFile.self, from: data)
            } catch {
                throw DoccMetadataParserError.invalidSymbolGraph(fileURL)
            }

            var skippedSymbolsForFile = 0
            for symbol in symbolGraph.symbols {
                guard let identifier = symbol.identifier,
                    let title = symbol.names?.title,
                    !identifier.isEmpty,
                    !title.isEmpty
                else {
                    skippedSymbolsForFile += 1
                    continue
                }
                let reference = DoccSymbolReference(
                    identifier: identifier,
                    title: title,
                    moduleName: symbolGraph.module.name)
                references.append(reference)
            }

            if skippedSymbolsForFile > 0 {
                logSkippedSymbols(count: skippedSymbolsForFile, fileURL: fileURL)
            }
        }

        return references.sorted { lhs, rhs in
            if lhs.identifier == rhs.identifier {
                return lhs.moduleName < rhs.moduleName
            }
            return lhs.identifier < rhs.identifier
        }
    }

    public func loadBundleDataMetadata(from bundleURL: URL) throws -> DoccBundleDataMetadata {
        let metadataURL =
            bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("metadata", isDirectory: true)
            .appendingPathComponent("metadata.json", isDirectory: false)

        let metadataData: Data
        do {
            metadataData = try Data(contentsOf: metadataURL)
        } catch {
            throw DoccMetadataParserError.metadataJSONMissing(metadataURL)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let rawMetadata: RawBundleDataMetadata
        do {
            rawMetadata = try decoder.decode(RawBundleDataMetadata.self, from: metadataData)
        } catch {
            throw DoccMetadataParserError.invalidMetadataJSON(metadataURL)
        }

        return DoccBundleDataMetadata(
            formatVersion: rawMetadata.formatVersion,
            generatedAt: rawMetadata.generatedAt,
            generator: rawMetadata.generator,
            kind: rawMetadata.kind)
    }

    public func loadTutorialPage(
        withIdentifier identifier: String,
        from bundleURL: URL
    ) throws -> DoccTutorial {
        let tutorialURL = makeTutorialFileURL(for: identifier, bundleURL: bundleURL)
        let data: Data
        do {
            data = try Data(contentsOf: tutorialURL)
        } catch {
            throw DoccMetadataParserError.tutorialPageMissing(tutorialURL)
        }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(DoccTutorial.self, from: data)
        } catch {
            throw DoccMetadataParserError.invalidTutorialPage(tutorialURL)
        }
    }

    public func loadArticlePage(
        withIdentifier identifier: String,
        from bundleURL: URL
    ) throws -> DoccArticle {
        let articleURL = makeArticleFileURL(for: identifier, bundleURL: bundleURL)
        let data: Data
        do {
            data = try Data(contentsOf: articleURL)
        } catch {
            throw DoccMetadataParserError.articlePageMissing(articleURL)
        }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(DoccArticle.self, from: data)
        } catch {
            throw DoccMetadataParserError.invalidArticlePage(articleURL)
        }
    }

    private func value(forKey key: String, in plist: [String: Any]) throws -> String {
        guard let rawValue = plist[key] else {
            throw DoccMetadataParserError.missingRequiredField(key)
        }
        guard let stringValue = rawValue as? String, !stringValue.isEmpty else {
            throw DoccMetadataParserError.invalidFieldType(
                key: key,
                expected: "non-empty String")
        }
        return stringValue
    }

    private func optionalValue(forKey key: String, in plist: [String: Any]) throws -> String? {
        guard let rawValue = plist[key] else { return nil }
        guard let stringValue = rawValue as? String else {
            throw DoccMetadataParserError.invalidFieldType(key: key, expected: "String")
        }
        let trimmedValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedValue.isEmpty {
            throw DoccMetadataParserError.invalidFieldType(key: key, expected: "non-empty String")
        }
        return trimmedValue
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
            throw DoccMetadataParserError.invalidFieldType(
                key: "Languages",
                expected: "non-empty strings")
        }
        return trimmed
    }

    private struct RawBundleDataMetadata: Decodable {
        let formatVersion: String
        let generatedAt: Date
        let generator: String
        let kind: String
    }
}

// MARK: - Private helpers

extension DoccMetadataParser {
    private func makeTutorialFileURL(for identifier: String, bundleURL: URL) -> URL {
        let slug = identifier.split(separator: "/").last.map(String.init) ?? identifier
        return bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("tutorials", isDirectory: true)
            .appendingPathComponent("\(slug).json", isDirectory: false)
    }

    private func makeArticleFileURL(for identifier: String, bundleURL: URL) -> URL {
        let slug = identifier.split(separator: "/").last.map(String.init) ?? identifier
        return bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("documentation", isDirectory: true)
            .appendingPathComponent("articles", isDirectory: true)
            .appendingPathComponent("\(slug).json", isDirectory: false)
    }

    private func logSkippedSymbols(count: Int, fileURL: URL) {
        let message =
            "DoccMetadataParser: skipped \(count) symbol(s) in \(fileURL.lastPathComponent) due to missing identifiers or titles.\n"
        if let data = message.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
}

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
