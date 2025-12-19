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

        private enum CodingKeys: String, CodingKey {
            case type
            case text
            case code
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)

            if let textValue = try container.decodeIfPresent(String.self, forKey: .text) {
                text = textValue
                return
            }

            if let codeValue = try container.decodeIfPresent(String.self, forKey: .code) {
                text = "`\(codeValue)`"
                return
            }

            text = ""
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(text, forKey: .text)
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

    public init(
        identifier: String,
        kind: String,
        title: String,
        role: String?,
        abstract: [AbstractItem],
        topics: [TopicSection]
    ) {
        self.identifier = identifier
        self.kind = kind
        self.title = title
        self.role = role
        self.abstract = abstract
        self.topics = topics
    }

    private enum CodingKeys: String, CodingKey {
        case identifier
        case kind
        case title
        case role
        case abstract
        case topics
    }

    // Swift-DocC render node keys.
    private enum RenderCodingKeys: String, CodingKey {
        case identifier
        case kind
        case abstract
        case topicSections
        case metadata
    }

    private struct RenderIdentifier: Decodable {
        let url: String
    }

    private struct RenderMetadata: Decodable {
        let title: String?
        let role: String?
    }

    private struct RenderTopicSection: Decodable {
        let title: String
        let identifiers: [String]
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Legacy format used by synthetic fixtures.
        if let decodedIdentifier = try? container.decode(String.self, forKey: .identifier),
           let decodedKind = try? container.decode(String.self, forKey: .kind),
           let decodedTitle = try? container.decode(String.self, forKey: .title)
        {
            identifier = decodedIdentifier
            kind = decodedKind
            title = decodedTitle
            role = try? container.decode(String.self, forKey: .role)
            abstract = (try? container.decode([AbstractItem].self, forKey: .abstract)) ?? []
            topics = (try? container.decode([TopicSection].self, forKey: .topics)) ?? []
            return
        }

        // Swift-DocC render archive module page.
        let renderContainer = try decoder.container(keyedBy: RenderCodingKeys.self)
        let renderIdentifier = try renderContainer.decode(RenderIdentifier.self, forKey: .identifier)
        let renderKind = try renderContainer.decode(String.self, forKey: .kind)
        let renderMetadata = try renderContainer.decode(RenderMetadata.self, forKey: .metadata)
        let renderTopics = (try? renderContainer.decode([RenderTopicSection].self, forKey: .topicSections)) ?? []

        identifier = renderIdentifier.url
        kind = renderKind
        title = renderMetadata.title ?? "Documentation Catalog"
        role = renderMetadata.role
        abstract = (try? renderContainer.decode([AbstractItem].self, forKey: .abstract)) ?? []
        topics = renderTopics.map { TopicSection(title: $0.title, identifiers: $0.identifiers) }
    }
}

public struct DoccArticle: Equatable, Codable {
    public struct AbstractItem: Equatable, Codable {
        public let type: String
        public let text: String

        public init(type: String, text: String) {
            self.type = type
            self.text = text
        }

        private enum CodingKeys: String, CodingKey {
            case type
            case text
            case code
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)

            if let textValue = try container.decodeIfPresent(String.self, forKey: .text) {
                text = textValue
                return
            }

            if let codeValue = try container.decodeIfPresent(String.self, forKey: .code) {
                text = "`\(codeValue)`"
                return
            }

            text = ""
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(text, forKey: .text)
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
        public let url: String?

        public init(identifier: String, kind: String, title: String, url: String? = nil) {
            self.identifier = identifier
            self.kind = kind
            self.title = title
            self.url = url
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

    // Swift-DocC render node keys.
    private enum RenderCodingKeys: String, CodingKey {
        case identifier
        case kind
        case abstract
        case metadata
        case references
        case primaryContentSections
        case topicSections
    }

    private struct RenderIdentifier: Decodable {
        let url: String
    }

    private struct RenderMetadata: Decodable {
        let title: String?
    }

    private struct RenderTopicSection: Decodable {
        let title: String
        let identifiers: [String]
    }

    private struct RenderReference: Decodable {
        let identifier: String?
        let kind: String?
        let title: String?
        let url: String?
    }

    private struct RenderPrimaryContentSection: Decodable {
        let content: [RenderContentBlock]?
    }

    private struct RenderContentBlock: Decodable {
        let type: String
        let text: String?
        let level: Int?
        let inlineContent: [RenderInlineContent]?
        let items: [RenderListItem]?
        let header: String?
        let rows: [[[RenderContentBlock]]]?
        let syntax: String?
        let code: String?
        let style: String?
        let name: String?
        let content: [RenderContentBlock]?
        let source: String?
        let altText: String?

        private enum CodingKeys: String, CodingKey {
            case type
            case text
            case level
            case inlineContent
            case items
            case header
            case rows
            case syntax
            case code
            case style
            case name
            case content
            case source
            case altText
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            text = try? container.decodeIfPresent(String.self, forKey: .text)
            level = try? container.decodeIfPresent(Int.self, forKey: .level)
            inlineContent = try? container.decodeIfPresent([RenderInlineContent].self, forKey: .inlineContent)
            items = try? container.decodeIfPresent([RenderListItem].self, forKey: .items)
            header = try? container.decodeIfPresent(String.self, forKey: .header)
            rows = try? container.decodeIfPresent([[[RenderContentBlock]]].self, forKey: .rows)
            syntax = try? container.decodeIfPresent(String.self, forKey: .syntax)
            style = try? container.decodeIfPresent(String.self, forKey: .style)
            name = try? container.decodeIfPresent(String.self, forKey: .name)
            content = try? container.decodeIfPresent([RenderContentBlock].self, forKey: .content)
            source = try? container.decodeIfPresent(String.self, forKey: .source)
            altText = try? container.decodeIfPresent(String.self, forKey: .altText)

            if let codeString = try? container.decodeIfPresent(String.self, forKey: .code) {
                code = codeString
            } else if let codeLines = try? container.decodeIfPresent([String].self, forKey: .code) {
                code = codeLines.joined(separator: "\n")
            } else {
                code = nil
            }
        }
    }

    private struct RenderInlineContent: Decodable {
        let type: String
        let text: String?
        let code: String?
        let inlineContent: [RenderInlineContent]?
        let identifier: String?
        let isActive: Bool?
        let href: String?
    }

    private struct RenderListItem: Decodable {
        let content: [RenderContentBlock]
    }

    private enum RenderContentType: String {
        case heading
        case paragraph
        case unorderedList
        case orderedList
        case codeListing
        case table
        case aside
        case image
        case termList
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Legacy format used by synthetic fixtures.
        if let decodedIdentifier = try? container.decode(String.self, forKey: .identifier),
           let decodedKind = try? container.decode(String.self, forKey: .kind),
           let decodedTitle = try? container.decode(String.self, forKey: .title)
        {
            identifier = decodedIdentifier
            kind = decodedKind
            title = decodedTitle
            abstract = (try? container.decode([AbstractItem].self, forKey: .abstract)) ?? []
            sections = (try? container.decode([Section].self, forKey: .sections)) ?? []
            topics = (try? container.decode([TopicSection].self, forKey: .topics)) ?? []
            references = (try? container.decode([Reference].self, forKey: .references)) ?? []
            return
        }

        // Swift-DocC render archive article page.
        let renderContainer = try decoder.container(keyedBy: RenderCodingKeys.self)
        let renderIdentifier = try renderContainer.decode(RenderIdentifier.self, forKey: .identifier)
        kind = try renderContainer.decode(String.self, forKey: .kind)
        let metadata = try renderContainer.decode(RenderMetadata.self, forKey: .metadata)

        identifier = renderIdentifier.url
        title = metadata.title ?? "Article"
        abstract = (try? renderContainer.decode([AbstractItem].self, forKey: .abstract)) ?? []

        let decodedPrimaryContent =
            (try? renderContainer.decode([RenderPrimaryContentSection].self, forKey: .primaryContentSections)) ?? []
        let decodedTopics = (try? renderContainer.decode([RenderTopicSection].self, forKey: .topicSections)) ?? []
        topics = decodedTopics.map { TopicSection(title: $0.title, identifiers: $0.identifiers) }

        let decodedReferences =
            (try? renderContainer.decode([String: RenderReference].self, forKey: .references)) ?? [:]
        references = Self.referencesForTopicSections(topics, from: decodedReferences)
        sections = Self.parseRenderArchiveSections(from: decodedPrimaryContent, references: decodedReferences)
    }

    private static func referencesForTopicSections(
        _ topicSections: [TopicSection],
        from lookup: [String: RenderReference]
    ) -> [Reference] {
        var seen: Set<String> = []
        var resolved: [Reference] = []

        for section in topicSections {
            for identifier in section.identifiers {
                guard seen.insert(identifier).inserted else { continue }
                guard let reference = lookup[identifier] else { continue }
                guard let title = reference.title, !title.isEmpty else { continue }
                let kind = reference.kind ?? "topic"
                let resolvedIdentifier = reference.identifier ?? identifier
                resolved.append(Reference(identifier: resolvedIdentifier, kind: kind, title: title, url: reference.url))
            }
        }

        return resolved
    }

    private static func parseRenderArchiveSections(
        from contentSections: [RenderPrimaryContentSection],
        references: [String: RenderReference]
    ) -> [Section] {
        var sections: [Section] = []
        sections.reserveCapacity(4)

        var currentTitle: String?
        var currentContent: [String] = []

        func flushSectionIfNeeded() {
            let title = currentTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !title.isEmpty || !currentContent.isEmpty else { return }
            let resolvedTitle = title.isEmpty ? "Overview" : title
            sections.append(Section(title: resolvedTitle, content: currentContent))
            currentTitle = nil
            currentContent = []
        }

        func resolveReference(_ identifier: String) -> String? {
            let candidate = references[identifier] ?? references.values.first(where: { $0.identifier == identifier })
            guard let candidate, let title = candidate.title, !title.isEmpty else { return nil }
            return title
        }

        func renderInlineText(from inlineContent: [RenderInlineContent]) -> String {
            var result = ""
            result.reserveCapacity(128)

            for item in inlineContent {
                switch item.type {
                case "text":
                    result.append(item.text ?? "")
                case "codeVoice":
                    if let code = item.code {
                        result.append("`\(code)`")
                    }
                case "strong":
                    result.append(renderInlineText(from: item.inlineContent ?? []))
                case "emphasis":
                    result.append(renderInlineText(from: item.inlineContent ?? []))
                case "strikethrough":
                    let strikeContent = renderInlineText(from: item.inlineContent ?? [])
                    result.append("~~\(strikeContent)~~")
                case "link":
                    if let href = item.href, !href.isEmpty {
                        let linkText = renderInlineText(from: item.inlineContent ?? [])
                        result.append("[\(linkText)](\(href))")
                    } else {
                        let linkText = renderInlineText(from: item.inlineContent ?? [])
                        result.append(linkText)
                    }
                case "reference":
                    guard let identifier = item.identifier else { continue }
                    if let title = resolveReference(identifier) {
                        let candidate = references[identifier] ?? references.values.first(where: { $0.identifier == identifier })
                        if let url = candidate?.url, !url.isEmpty {
                            result.append("[\(title)](\(url))")
                        } else {
                            result.append(title)
                        }
                    }
                default:
                    // For unknown inline types, render any nested content as fallback
                    if let nestedContent = item.inlineContent {
                        result.append(renderInlineText(from: nestedContent))
                    }
                }
            }

            return result
        }

        func renderContentBlocks(_ blocks: [RenderContentBlock]) -> [String] {
            var rendered: [String] = []
            rendered.reserveCapacity(blocks.count)

            for block in blocks {
                switch RenderContentType(rawValue: block.type) {
                case .heading:
                    let level = max(1, min(6, block.level ?? 2))
                    let hashes = String(repeating: "#", count: level)
                    let text = (block.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty { rendered.append("\(hashes) \(text)") }
                case .paragraph:
                    let paragraph = renderInlineText(from: block.inlineContent ?? [])
                    let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty { rendered.append(trimmed) }
                case .unorderedList:
                    for item in block.items ?? [] {
                        let parts = renderContentBlocks(item.content)
                        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        rendered.append("- \(text.isEmpty ? "_" : text)")
                    }
                case .orderedList:
                    let items = block.items ?? []
                    for (index, item) in items.enumerated() {
                        let parts = renderContentBlocks(item.content)
                        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        rendered.append("\(index + 1). \(text.isEmpty ? "_" : text)")
                    }
                case .codeListing:
                    let syntax = (block.syntax ?? "swift").trimmingCharacters(in: .whitespacesAndNewlines)
                    let code = (block.code ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !code.isEmpty { rendered.append("```\(syntax)\n\(code)\n```") }
                case .table:
                    let rows = block.rows ?? []
                    guard !rows.isEmpty else { break }

                    func renderCell(_ cellBlocks: [RenderContentBlock]) -> String {
                        let parts = renderContentBlocks(cellBlocks)
                        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        let singleLine = text
                            .replacingOccurrences(of: "\n\n", with: "\n")
                            .replacingOccurrences(of: "\n", with: "<br>")
                        return singleLine.isEmpty ? "_" : singleLine
                    }

                    func renderRow(_ row: [[RenderContentBlock]]) -> [String] {
                        row.map(renderCell)
                    }

                    var renderedRows = rows.map(renderRow)
                    if renderedRows.isEmpty { break }
                    let isHeaderRow = (block.header ?? "").lowercased() == "row"
                    let header = isHeaderRow ? renderedRows.removeFirst() : Array(repeating: "", count: renderedRows[0].count)
                    let columnCount = header.count

                    let headerLine = "| " + header.map { $0.replacingOccurrences(of: "|", with: "\\|") }.joined(separator: " | ") + " |"
                    let separatorLine = "| " + Array(repeating: "---", count: columnCount).joined(separator: " | ") + " |"
                    rendered.append(headerLine)
                    rendered.append(separatorLine)

                    for row in renderedRows {
                        let normalized = row.count == columnCount
                            ? row
                            : (row + Array(repeating: "", count: max(0, columnCount - row.count)))
                        let rowLine = "| " + normalized.prefix(columnCount).map { $0.replacingOccurrences(of: "|", with: "\\|") }.joined(separator: " | ") + " |"
                        rendered.append(rowLine)
                    }
                case .aside:
                    let asideContent = block.content ?? []
                    let renderedAsideBlocks = renderContentBlocks(asideContent)

                    if !renderedAsideBlocks.isEmpty {
                        let style = (block.style ?? "note").lowercased()
                        let stylePrefix: String
                        switch style {
                        case "warning":
                            stylePrefix = "**Warning:**"
                        case "important":
                            stylePrefix = "**Important:**"
                        case "tip":
                            stylePrefix = "**Tip:**"
                        default:
                            stylePrefix = "**Note:**"
                        }

                        for (index, asideLine) in renderedAsideBlocks.enumerated() {
                            if index == 0 {
                                rendered.append("> \(stylePrefix) \(asideLine)")
                            } else {
                                rendered.append("> \(asideLine)")
                            }
                        }
                    }
                case .image:
                    if let source = block.source, !source.isEmpty {
                        let altText = block.altText ?? "Image"
                        rendered.append("![\(altText)](\(source))")
                    }
                case .termList:
                    // Handle term list items - render as definition list format
                    if let items = block.items {
                        for item in items {
                            let itemContent = renderContentBlocks(item.content)
                            let itemText = itemContent.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                            if !itemText.isEmpty { rendered.append("\(itemText)") }
                        }
                    }
                case .none:
                    continue
                }
            }

            return rendered
        }

        for contentSection in contentSections {
            for block in contentSection.content ?? [] {
                switch RenderContentType(rawValue: block.type) {
                case .heading:
                    flushSectionIfNeeded()
                    currentTitle = block.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                case .paragraph, .unorderedList, .orderedList, .codeListing, .table, .aside, .image, .termList:
                    currentContent.append(contentsOf: renderContentBlocks([block]))
                case .none:
                    continue
                }
            }
        }

        flushSectionIfNeeded()
        return sections
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

    private enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case introduction
        case steps
        case assessments
    }

    // Swift-DocC render archive tutorial (project) keys.
    private enum RenderCodingKeys: String, CodingKey {
        case identifier
        case kind
        case metadata
        case sections
        case references
    }

    private struct RenderIdentifier: Decodable {
        let url: String
    }

    private struct RenderMetadata: Decodable {
        let title: String?
        let role: String?
    }

    private struct RenderInlineContent: Decodable {
        let type: String
        let text: String?
        let code: String?
        let inlineContent: [RenderInlineContent]?
        let identifier: String?
    }

    private struct RenderContentBlock: Decodable {
        let type: String
        let inlineContent: [RenderInlineContent]?
        let items: [RenderListItem]?
    }

    private struct RenderListItem: Decodable {
        let content: [RenderContentBlock]
    }

    private struct RenderContentAndMedia: Decodable {
        let kind: String?
        let content: [RenderContentBlock]?
    }

    private struct RenderStep: Decodable {
        let type: String?
        let content: [RenderContentBlock]?
        let code: String?
    }

    private struct RenderTask: Decodable {
        let title: String?
        let anchor: String?
        let contentSection: [RenderContentAndMedia]?
        let stepsSection: [RenderStep]?
    }

    private struct RenderSection: Decodable {
        let kind: String
        let title: String?
        let content: [RenderContentBlock]?
        let tasks: [RenderTask]?
    }

    private struct RenderReference: Decodable {
        struct AbstractItem: Decodable {
            let type: String
            let text: String?
            let code: String?
        }

        let identifier: String?
        let title: String?
        let abstract: [AbstractItem]?
        let fileName: String?
        let syntax: String?
        let content: [String]?

        private enum CodingKeys: String, CodingKey {
            case identifier
            case title
            case abstract
            case fileName
            case syntax
            case content
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Legacy synthetic format.
        if let decodedIdentifier = try? container.decode(String.self, forKey: .identifier),
           let decodedTitle = try? container.decode(String.self, forKey: .title)
        {
            identifier = decodedIdentifier
            title = decodedTitle
            introduction = try? container.decodeIfPresent(String.self, forKey: .introduction)
            steps = (try? container.decode([Step].self, forKey: .steps)) ?? []
            assessments = (try? container.decode([Assessment].self, forKey: .assessments)) ?? []
            return
        }

        // Swift-DocC render archive "project" tutorial page.
        let renderContainer = try decoder.container(keyedBy: RenderCodingKeys.self)
        let renderIdentifier = try renderContainer.decode(RenderIdentifier.self, forKey: .identifier)
        let kind = try renderContainer.decode(String.self, forKey: .kind)
        let metadata = try renderContainer.decode(RenderMetadata.self, forKey: .metadata)
        let sections = (try? renderContainer.decode([RenderSection].self, forKey: .sections)) ?? []
        let references = (try? renderContainer.decode([String: RenderReference].self, forKey: .references)) ?? [:]

        guard kind == "project" else {
            throw DecodingError.dataCorruptedError(
                forKey: .kind,
                in: renderContainer,
                debugDescription: "Unsupported tutorial render node kind: \(kind)")
        }

        let identifierURL = renderIdentifier.url
        identifier = identifierURL
        title = metadata.title ?? "Tutorial"

        func renderInlineText(_ items: [RenderInlineContent]) -> String {
            items.map { item in
                switch item.type {
                case "text":
                    return item.text ?? ""
                case "codeVoice":
                    let code = item.code ?? ""
                    return code.isEmpty ? "" : "`\(code)`"
                case "strong", "emphasis":
                    return renderInlineText(item.inlineContent ?? [])
                case "reference":
                    guard let refID = item.identifier else { return "" }
                    let candidate = references[refID] ?? references.values.first(where: { $0.identifier == refID })
                    return candidate?.title ?? ""
                default:
                    return item.text ?? item.code ?? ""
                }
            }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        func renderBlocks(_ blocks: [RenderContentBlock]) -> [String] {
            var rendered: [String] = []
            rendered.reserveCapacity(blocks.count)

            for block in blocks {
                switch block.type {
                case "paragraph":
                    let text = renderInlineText(block.inlineContent ?? [])
                    if !text.isEmpty { rendered.append(text) }
                case "unorderedList":
                    let items = block.items ?? []
                    for item in items {
                        let parts = renderBlocks(item.content)
                        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        rendered.append("- \(text.isEmpty ? "_" : text)")
                    }
                default:
                    continue
                }
            }

            return rendered
        }

        // Intro from hero content.
        let hero = sections.first(where: { $0.kind == "hero" })
        let heroParagraphs = hero.flatMap { renderBlocks($0.content ?? []) } ?? []
        let resolvedIntroduction = heroParagraphs.isEmpty ? nil : heroParagraphs.joined(separator: "\n\n")
        introduction = resolvedIntroduction
        let firstIntroParagraph = heroParagraphs.first?.trimmingCharacters(in: .whitespacesAndNewlines)

        // Steps from tasks list + optional abstract from reference map keyed by anchor.
        let tasksSection = sections.first(where: { $0.kind == "tasks" })
        let tasks = tasksSection?.tasks ?? []
        let resolvedSteps: [Step] = tasks.map { task in
            let stepTitle = (task.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let anchor = (task.anchor ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let refKey = anchor.isEmpty ? nil : "\(identifierURL)#\(anchor)"

            var content: [String] = []

            // Section-level intro content.
            for section in (task.contentSection ?? []) {
                content.append(contentsOf: renderBlocks(section.content ?? []))
            }

            // Step-by-step content.
            let stepsSection = task.stepsSection ?? []
            for (index, step) in stepsSection.enumerated() {
                let renderedStepBlocks = renderBlocks(step.content ?? [])
                if !renderedStepBlocks.isEmpty {
                    content.append("##### Step \(index + 1)")
                    content.append(contentsOf: renderedStepBlocks)
                }

                if let codeRef = step.code,
                   let file = references[codeRef],
                   let lines = file.content,
                   !lines.isEmpty
                {
                    let syntax = (file.syntax ?? "swift").trimmingCharacters(in: .whitespacesAndNewlines)
                    let code = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !code.isEmpty {
                        if let fileName = file.fileName?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !fileName.isEmpty
                        {
                            content.append("**\(fileName)**")
                        }
                        content.append("```\(syntax)\n\(code)\n```")
                    }
                }
            }

            // Fallback to the task reference abstract if there was no rich content.
            if content.isEmpty, let refKey, let reference = references[refKey] {
                let abstract = reference.abstract ?? []
                let abstractText = abstract.compactMap { item -> String? in
                    if item.type == "codeVoice", let code = item.code { return "`\(code)`" }
                    let text = item.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    return text.isEmpty ? nil : text
                }
                content.append(contentsOf: abstractText)
            }

            return Step(title: stepTitle.isEmpty ? "Step" : stepTitle, content: content)
        }
        let uniqueStepContent = Set(resolvedSteps.flatMap(\.content))
        let shouldSuppressStepContent =
            uniqueStepContent.count == 1 &&
            firstIntroParagraph == uniqueStepContent.first

        steps = shouldSuppressStepContent
            ? resolvedSteps.map { Step(title: $0.title, content: []) }
            : resolvedSteps

        assessments = []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(introduction, forKey: .introduction)
        try container.encode(steps, forKey: .steps)
        try container.encode(assessments, forKey: .assessments)
    }
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
    /// Loads DocC bundle metadata and pages from either:
    /// - a classic DocC bundle directory (with `Info.plist` and `data/`), or
    /// - a Swift-DocC render archive directory (`.doccarchive`) produced by `swift package generate-documentation`.
    ///
    /// The parser is used by `MarkdownGenerationPipeline` and prefers deterministic behavior:
    /// - file enumeration is sorted
    /// - optional, non-critical inputs are treated as recoverable when possible
    /// - render-archive inputs synthesize minimal metadata so conversion can proceed offline
    public init() {}

    public func loadInfoPlist(from bundleURL: URL) throws -> DoccBundleMetadata {
        let infoPlistURL = bundleURL.appendingPathComponent("Info.plist", isDirectory: false)
        let plistData: Data

        do {
            plistData = try Data(contentsOf: infoPlistURL)
        } catch {
            if let metadata = try? loadSwiftDocCRenderArchiveMetadata(from: bundleURL) {
                return metadata
            }
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

        if FileManager.default.fileExists(atPath: metadataURL.path) {
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

        // Swift-DocC render archive fallback: synthesize a minimal metadata payload.
        if let renderMetadata = try? synthesizeRenderMetadata(from: bundleURL) {
            return renderMetadata
        }

        throw DoccMetadataParserError.renderMetadataMissing(metadataURL)
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
            if let references = try? loadSwiftDocCRenderArchiveSymbolReferences(from: bundleURL) {
                return references
            }
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
            let resolvedFileURL = fileURL.resolvingSymlinksInPath()
            let data = try Data(contentsOf: resolvedFileURL)
            let symbolGraph: SymbolGraphFile
            do {
                symbolGraph = try JSONDecoder().decode(SymbolGraphFile.self, from: data)
            } catch {
                throw DoccMetadataParserError.invalidSymbolGraph(resolvedFileURL)
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
                logSkippedSymbols(count: skippedSymbolsForFile, fileURL: resolvedFileURL)
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
            if let synthesized = try? synthesizeBundleDataMetadata(from: bundleURL) {
                return synthesized
            }
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
    private struct SwiftDocCRenderArchiveRootMetadata: Decodable {
        struct SchemaVersion: Decodable {
            let major: Int
            let minor: Int
            let patch: Int
        }

        let bundleDisplayName: String
        let bundleID: String
        let schemaVersion: SchemaVersion?
    }

    private struct SwiftDocCRenderNodeHeader: Decodable {
        struct Identifier: Decodable {
            let url: String
        }

        struct Module: Decodable {
            let name: String
        }

        struct Metadata: Decodable {
            let title: String?
            let role: String?
            let modules: [Module]?
        }

        let kind: String
        let identifier: Identifier
        let metadata: Metadata?
    }

    private func isSwiftDocCRenderArchive(_ bundleURL: URL) -> Bool {
        let rootMetadataURL = bundleURL.appendingPathComponent("metadata.json", isDirectory: false)
        let indexURL = bundleURL.appendingPathComponent("index/index.json", isDirectory: false)
        return FileManager.default.fileExists(atPath: rootMetadataURL.path) ||
            FileManager.default.fileExists(atPath: indexURL.path)
    }

    private func loadSwiftDocCRenderArchiveMetadata(from bundleURL: URL) throws -> DoccBundleMetadata? {
        guard isSwiftDocCRenderArchive(bundleURL) else { return nil }

        let rootMetadataURL = bundleURL.appendingPathComponent("metadata.json", isDirectory: false)
        guard FileManager.default.fileExists(atPath: rootMetadataURL.path) else { return nil }

        let data = try Data(contentsOf: rootMetadataURL)
        let decoded = try JSONDecoder().decode(SwiftDocCRenderArchiveRootMetadata.self, from: data)

        let technologyRoot = decoded.bundleDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return DoccBundleMetadata(
            identifier: decoded.bundleID,
            displayName: decoded.bundleDisplayName,
            technologyRoot: technologyRoot,
            locales: ["en"],
            doccVersion: nil,
            projectVersion: nil)
    }

    private func synthesizeRenderMetadata(from bundleURL: URL) throws -> DoccRenderMetadata? {
        guard isSwiftDocCRenderArchive(bundleURL) else { return nil }

        let rootMetadataURL = bundleURL.appendingPathComponent("metadata.json", isDirectory: false)
        guard FileManager.default.fileExists(atPath: rootMetadataURL.path) else { return nil }

        let data = try Data(contentsOf: rootMetadataURL)
        let decoded = try JSONDecoder().decode(SwiftDocCRenderArchiveRootMetadata.self, from: data)
        let schema = decoded.schemaVersion
        let versionString = schema.map { "\($0.major).\($0.minor).\($0.patch)" } ?? "0.0.0"

        return DoccRenderMetadata(
            formatVersion: versionString,
            generatedAt: "",
            generator: "swift-docc-plugin",
            kind: "render-archive")
    }

    private func synthesizeBundleDataMetadata(from bundleURL: URL) throws -> DoccBundleDataMetadata? {
        guard isSwiftDocCRenderArchive(bundleURL) else { return nil }
        return DoccBundleDataMetadata(
            formatVersion: "0.0.0",
            generatedAt: Date(timeIntervalSince1970: 0),
            generator: "swift-docc-plugin",
            kind: "render-archive")
    }

    private func documentationDataRoot(in bundleURL: URL) -> URL {
        bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("documentation", isDirectory: true)
    }

    private func documentationJSONFiles(in bundleURL: URL) -> [URL] {
        let root = documentationDataRoot(in: bundleURL)
        guard FileManager.default.fileExists(atPath: root.path) else { return [] }

        let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        let urls = (enumerator?.allObjects as? [URL] ?? [])
            .filter { $0.pathExtension.lowercased() == "json" }
            .sorted { $0.path < $1.path }
        return urls
    }

    private func loadSwiftDocCRenderArchiveSymbolReferences(from bundleURL: URL) throws -> [DoccSymbolReference]? {
        guard isSwiftDocCRenderArchive(bundleURL) else { return nil }

        var references: [DoccSymbolReference] = []
        references.reserveCapacity(128)

        for fileURL in documentationJSONFiles(in: bundleURL) {
            let data = try Data(contentsOf: fileURL)
            guard let header = try? JSONDecoder().decode(SwiftDocCRenderNodeHeader.self, from: data) else {
                continue
            }

            guard header.kind == "symbol",
                  header.metadata?.role == "symbol",
                  let title = header.metadata?.title,
                  !title.isEmpty
            else {
                continue
            }

            let moduleName = header.metadata?.modules?.first?.name ?? "UnknownModule"
            references.append(
                DoccSymbolReference(
                    identifier: header.identifier.url,
                    title: title,
                    moduleName: moduleName)
            )
        }

        return references.sorted { lhs, rhs in
            if lhs.identifier == rhs.identifier {
                return lhs.moduleName < rhs.moduleName
            }
            return lhs.identifier < rhs.identifier
        }
    }

    public func loadSwiftDocCRenderArchiveSymbolPages(from bundleURL: URL) throws -> [String: DoccSymbolPage] {
        guard isSwiftDocCRenderArchive(bundleURL) else { return [:] }

        struct KindProbe: Decodable { let kind: String }

        struct RenderNode: Decodable {
            struct Identifier: Decodable { let url: String }
            struct Module: Decodable { let name: String }
            struct Metadata: Decodable {
                let title: String?
                let roleHeading: String?
                let symbolKind: String?
                let role: String?
                let modules: [Module]?
            }

            struct TopicSection: Decodable {
                let title: String
                let identifiers: [String]

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    title = (try? container.decode(String.self, forKey: .title)) ?? ""
                    identifiers = (try? container.decode([String].self, forKey: .identifiers)) ?? []
                }

                private enum CodingKeys: String, CodingKey {
                    case title
                    case identifiers
                }
            }

            struct RelationshipSection: Decodable {
                let title: String
                let identifiers: [String]

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    title = (try? container.decode(String.self, forKey: .title)) ?? ""
                    identifiers = (try? container.decode([String].self, forKey: .identifiers)) ?? []
                }

                private enum CodingKeys: String, CodingKey {
                    case title
                    case identifiers
                }
            }

            struct DeclarationToken: Decodable {
                let text: String
            }

            struct Declaration: Decodable {
                let languages: [String]?
                let tokens: [DeclarationToken]
            }

            struct InlineContent: Decodable {
                let type: String
                let text: String?
                let code: String?
                let inlineContent: [InlineContent]?
                let identifier: String?
                let isActive: Bool?
            }

            struct ContentBlock: Decodable {
                let type: String
                let level: Int?
                let text: String?
                let inlineContent: [InlineContent]?
                let style: String?
                let content: [ContentBlock]?
                let items: [ListItem]?
                let header: String?
                let rows: [[[ContentBlock]]]?
                let syntax: String?
                let code: String?

                private enum CodingKeys: String, CodingKey {
                    case type
                    case level
                    case text
                    case inlineContent
                    case style
                    case content
                    case items
                    case header
                    case rows
                    case syntax
                    case code
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    type = try container.decode(String.self, forKey: .type)
                    level = try? container.decodeIfPresent(Int.self, forKey: .level)
                    text = try? container.decodeIfPresent(String.self, forKey: .text)
                    inlineContent = try? container.decodeIfPresent([InlineContent].self, forKey: .inlineContent)
                    style = try? container.decodeIfPresent(String.self, forKey: .style)
                    content = try? container.decodeIfPresent([ContentBlock].self, forKey: .content)
                    items = try? container.decodeIfPresent([ListItem].self, forKey: .items)
                    header = try? container.decodeIfPresent(String.self, forKey: .header)
                    rows = try? container.decodeIfPresent([[[ContentBlock]]].self, forKey: .rows)
                    syntax = try? container.decodeIfPresent(String.self, forKey: .syntax)

                    if let codeString = try? container.decodeIfPresent(String.self, forKey: .code) {
                        code = codeString
                    } else if let codeLines = try? container.decodeIfPresent([String].self, forKey: .code) {
                        code = codeLines.joined(separator: "\n")
                    } else {
                        code = nil
                    }
                }
            }

            struct ListItem: Decodable {
                let content: [ContentBlock]
            }

            struct Parameter: Decodable {
                let name: String
                let content: [ContentBlock]
            }

            struct PrimaryContentSection: Decodable {
                let kind: String?
                let declarations: [Declaration]?
                let content: [ContentBlock]?
                let parameters: [Parameter]?
            }

            struct Reference: Decodable {
                let identifier: String?
                let kind: String?
                let title: String?
                let url: String?

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    identifier = try? container.decodeIfPresent(String.self, forKey: .identifier)
                    kind = try? container.decodeIfPresent(String.self, forKey: .kind)
                    title = try? container.decodeIfPresent(String.self, forKey: .title)
                    url = try? container.decodeIfPresent(String.self, forKey: .url)
                }

                private enum CodingKeys: String, CodingKey {
                    case identifier
                    case kind
                    case title
                    case url
                }
            }

            let kind: String
            let identifier: Identifier
            let abstract: [InlineContent]?
            let topicSections: [TopicSection]?
            let relationshipsSections: [RelationshipSection]?
            let primaryContentSections: [PrimaryContentSection]?
            let metadata: Metadata
            let references: [String: Reference]?
        }

        func renderInlineText(
            from items: [RenderNode.InlineContent],
            resolveReference: ((String) -> String?)? = nil
        ) -> String {
            items.map { item in
                switch item.type {
                case "text":
                    return item.text ?? ""
                case "codeVoice":
                    let code = item.code ?? item.text ?? ""
                    return code.isEmpty ? "" : "`\(code)`"
                case "strong", "emphasis":
                    return renderInlineText(from: item.inlineContent ?? [], resolveReference: resolveReference)
                case "reference":
                    guard let identifier = item.identifier else { return "" }
                    return resolveReference?(identifier) ?? ""
                default:
                    return item.text ?? item.code ?? ""
                }
            }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        func renderContentBlocks(
            _ blocks: [RenderNode.ContentBlock],
            headingLevelOffset: Int,
            resolveReference: ((String) -> String?)? = nil
        ) -> [String] {
            var rendered: [String] = []
            rendered.reserveCapacity(blocks.count)

            for block in blocks {
                switch block.type {
                case "heading":
                    let level = max(1, min(6, (block.level ?? 2) + headingLevelOffset))
                    let hashes = String(repeating: "#", count: level)
                    let text = (block.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { continue }
                    rendered.append("\(hashes) \(text)")
                case "paragraph":
                    let text = renderInlineText(from: block.inlineContent ?? [], resolveReference: resolveReference)
                    guard !text.isEmpty else { continue }
                    rendered.append(text)
                case "unorderedList":
                    let items = block.items ?? []
                    for item in items {
                        let parts = renderContentBlocks(
                            item.content,
                            headingLevelOffset: headingLevelOffset,
                            resolveReference: resolveReference
                        )
                        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        rendered.append("- \(text.isEmpty ? "_" : text)")
                    }
                case "orderedList":
                    let items = block.items ?? []
                    for (index, item) in items.enumerated() {
                        let parts = renderContentBlocks(
                            item.content,
                            headingLevelOffset: headingLevelOffset,
                            resolveReference: resolveReference
                        )
                        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        rendered.append("\(index + 1). \(text.isEmpty ? "_" : text)")
                    }
                case "table":
                    let rows = block.rows ?? []
                    guard !rows.isEmpty else { continue }

                    func renderCell(_ blocks: [RenderNode.ContentBlock]) -> String {
                        let parts = renderContentBlocks(
                            blocks,
                            headingLevelOffset: headingLevelOffset,
                            resolveReference: resolveReference
                        )
                        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        let singleLine = text
                            .replacingOccurrences(of: "\n\n", with: "\n")
                            .replacingOccurrences(of: "\n", with: "<br>")
                        return singleLine.isEmpty ? "_" : singleLine
                    }

                    func renderRow(_ row: [[RenderNode.ContentBlock]]) -> [String] {
                        row.map(renderCell)
                    }

                    var renderedRows = rows.map(renderRow)
                    if renderedRows.isEmpty { continue }

                    let isHeaderRow = (block.header ?? "").lowercased() == "row"
                    let header = isHeaderRow ? renderedRows.removeFirst() : Array(repeating: "", count: renderedRows[0].count)
                    let columnCount = header.count
                    let normalizedBody = renderedRows.map { row -> [String] in
                        if row.count == columnCount { return row }
                        if row.count < columnCount { return row + Array(repeating: "", count: columnCount - row.count) }
                        return Array(row.prefix(columnCount))
                    }

                    let headerLine = "| " + header.map { $0.replacingOccurrences(of: "|", with: "\\|") }.joined(separator: " | ") + " |"
                    let separatorLine = "| " + Array(repeating: "---", count: columnCount).joined(separator: " | ") + " |"
                    rendered.append(headerLine)
                    rendered.append(separatorLine)
                    for row in normalizedBody {
                        let rowLine = "| " + row.map { $0.replacingOccurrences(of: "|", with: "\\|") }.joined(separator: " | ") + " |"
                        rendered.append(rowLine)
                    }
                case "aside":
                    let style = (block.style ?? "note").trimmingCharacters(in: .whitespacesAndNewlines)
                    let label = style.isEmpty ? "Note" : style.capitalized
                    let inner = renderContentBlocks(
                        block.content ?? [],
                        headingLevelOffset: headingLevelOffset,
                        resolveReference: resolveReference
                    )
                    let innerText = inner.joined(separator: "\n\n")
                    guard !innerText.isEmpty else { continue }
                    let quoted = innerText.replacingOccurrences(of: "\n", with: "\n> ")
                    rendered.append("> **\(label):** \(quoted)")
                case "codeListing":
                    let syntax = (block.syntax ?? "swift").trimmingCharacters(in: .whitespacesAndNewlines)
                    let code = (block.code ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !code.isEmpty else { continue }
                    rendered.append("```\(syntax)\n\(code)\n```")
                default:
                    continue
                }
            }

            return rendered
        }

        func makeSymbolPage(from node: RenderNode) -> DoccSymbolPage {
            let moduleName = node.metadata.modules?.first?.name
            let resolveReference: (String) -> String? = { identifier in
                guard let references = node.references else { return nil }
                let candidate = references[identifier] ?? references.values.first(where: { $0.identifier == identifier })
                guard let candidate else { return nil }
                guard let title = candidate.title, !title.isEmpty else { return nil }
                if let url = candidate.url, !url.isEmpty {
                    return "[\(title)](\(url))"
                }
                return title
            }
            let topicSections = (node.topicSections ?? []).map {
                DoccSymbolPage.TopicSection(title: $0.title, identifiers: $0.identifiers)
            }
            let relationshipSections = (node.relationshipsSections ?? []).map {
                DoccSymbolPage.RelationshipSection(title: $0.title, identifiers: $0.identifiers)
            }

            var declarations: [DoccSymbolPage.Declaration] = []
            var discussionBlocks: [String] = []
            for section in node.primaryContentSections ?? [] {
                if section.kind == "content", let content = section.content {
                    discussionBlocks.append(contentsOf: renderContentBlocks(
                        content,
                        headingLevelOffset: 1,
                        resolveReference: resolveReference
                    ))
                }
                if section.kind == "parameters", let parameters = section.parameters {
                    var lines: [String] = []
                    lines.append("### Parameters")
                    for parameter in parameters {
                        let rendered = renderContentBlocks(
                            parameter.content,
                            headingLevelOffset: 0,
                            resolveReference: resolveReference
                        )
                        let text = rendered.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        lines.append("- `\(parameter.name)`: \(text.isEmpty ? "_" : text)")
                    }
                    discussionBlocks.append(lines.joined(separator: "\n"))
                }
                for declaration in section.declarations ?? [] {
                    let text = declaration.tokens.map(\.text).joined()
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { continue }
                    declarations.append(
                        DoccSymbolPage.Declaration(
                            language: declaration.languages?.first,
                            text: text
                        )
                    )
                }
            }

            var referencesByIdentifier: [String: DoccSymbolPage.Reference] = [:]
            for (key, reference) in (node.references ?? [:]) {
                guard let title = reference.title, !title.isEmpty else { continue }
                let kind = reference.kind ?? "topic"
                referencesByIdentifier[key] = DoccSymbolPage.Reference(
                    identifier: reference.identifier ?? key,
                    kind: kind,
                    title: title,
                    urlPath: reference.url
                )
            }

            let abstractText = node.abstract.map { renderInlineText(from: $0, resolveReference: resolveReference) }
            let pageTitle = node.metadata.title ?? node.identifier.url
            return DoccSymbolPage(
                identifier: node.identifier.url,
                title: pageTitle,
                abstract: abstractText,
                discussion: discussionBlocks,
                symbolKind: node.metadata.symbolKind,
                roleHeading: node.metadata.roleHeading,
                moduleName: moduleName,
                topicSections: topicSections,
                relationshipSections: relationshipSections,
                declarations: declarations,
                referencesByIdentifier: referencesByIdentifier
            )
        }

        func decodeSymbolPageLossy(from data: Data, decoder: JSONDecoder) -> DoccSymbolPage? {
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                return nil
            }

            func dataFor(_ value: Any?) -> Data? {
                guard let value else { return nil }
                return try? JSONSerialization.data(withJSONObject: value)
            }

            guard let identifierValue = json["identifier"] as? [String: Any],
                  let identifierURL = identifierValue["url"] as? String,
                  let metadataValue = json["metadata"] as? [String: Any]
            else {
                return nil
            }

            let title = (metadataValue["title"] as? String) ?? identifierURL
            let roleHeading = metadataValue["roleHeading"] as? String
            let symbolKind = metadataValue["symbolKind"] as? String
            let moduleName = ((metadataValue["modules"] as? [[String: Any]])?.first?["name"] as? String)

            let abstractItems = (json["abstract"] as? [[String: Any]]) ?? []
            let abstractText = abstractItems.map { item -> String in
                let type = item["type"] as? String
                if type == "codeVoice", let code = item["code"] as? String {
                    return "`\(code)`"
                }
                return (item["text"] as? String) ?? ""
            }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)

            let topicSectionsRaw = (json["topicSections"] as? [[String: Any]]) ?? []
            let topicSections = topicSectionsRaw.compactMap { section -> DoccSymbolPage.TopicSection? in
                guard let title = section["title"] as? String else { return nil }
                let identifiers = (section["identifiers"] as? [String]) ?? []
                return DoccSymbolPage.TopicSection(title: title, identifiers: identifiers)
            }

            let relationshipSectionsRaw =
                (json["relationshipsSections"] as? [[String: Any]]) ??
                (json["relationshipSections"] as? [[String: Any]]) ??
                []
            let relationshipSections = relationshipSectionsRaw.compactMap { section -> DoccSymbolPage.RelationshipSection? in
                guard let title = section["title"] as? String else { return nil }
                let identifiers = (section["identifiers"] as? [String]) ?? []
                return DoccSymbolPage.RelationshipSection(title: title, identifiers: identifiers)
            }

            var referencesByIdentifier: [String: DoccSymbolPage.Reference] = [:]
            if let referencesRaw = json["references"] as? [String: Any] {
                for (key, value) in referencesRaw {
                    guard let ref = value as? [String: Any] else { continue }
                    guard let title = ref["title"] as? String, !title.isEmpty else { continue }
                    let kind = (ref["kind"] as? String) ?? "topic"
                    let identifier = (ref["identifier"] as? String) ?? key
                    let urlPath = ref["url"] as? String
                    referencesByIdentifier[key] = DoccSymbolPage.Reference(
                        identifier: identifier,
                        kind: kind,
                        title: title,
                        urlPath: urlPath
                    )
                }
            }

            var declarations: [DoccSymbolPage.Declaration] = []
            var discussionBlocks: [String] = []
            if let primarySections = json["primaryContentSections"] as? [[String: Any]] {
                for section in primarySections {
                    let kind = section["kind"] as? String
                    if kind == "declarations", let decls = section["declarations"] as? [[String: Any]] {
                        for decl in decls {
                            let languages = decl["languages"] as? [String]
                            let language = languages?.first
                            let tokens = (decl["tokens"] as? [[String: Any]]) ?? []
                            let text = tokens.compactMap { $0["text"] as? String }.joined()
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !text.isEmpty else { continue }
                            declarations.append(DoccSymbolPage.Declaration(language: language, text: text))
                        }
                    }
                    if kind == "content", let content = section["content"] as? [[String: Any]] {
                        let contentData = dataFor(content) ?? Data()
                        if let decodedBlocks = try? decoder.decode([RenderNode.ContentBlock].self, from: contentData) {
                            discussionBlocks.append(contentsOf: renderContentBlocks(decodedBlocks, headingLevelOffset: 1))
                        } else {
                            // Best-effort manual parse for common heading/paragraph shapes.
                            for block in content {
                                guard let type = block["type"] as? String else { continue }
                                if type == "heading", let text = block["text"] as? String {
                                    let level = max(1, min(6, (block["level"] as? Int ?? 2) + 1))
                                    discussionBlocks.append("\(String(repeating: "#", count: level)) \(text)")
                                } else if type == "paragraph", let inline = block["inlineContent"] as? [[String: Any]] {
                                    let text = inline.map { item -> String in
                                        let t = item["type"] as? String
                                        if t == "codeVoice", let code = item["code"] as? String { return "`\(code)`" }
                                        return (item["text"] as? String) ?? ""
                                    }.joined().trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !text.isEmpty { discussionBlocks.append(text) }
                                } else if type == "codeListing" {
                                    let syntax = ((block["syntax"] as? String) ?? "swift").trimmingCharacters(in: .whitespacesAndNewlines)
                                    let code = ((block["code"] as? String) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !code.isEmpty {
                                        discussionBlocks.append("```\(syntax)\n\(code)\n```")
                                    }
                                } else if type == "unorderedList", let items = block["items"] as? [[String: Any]] {
                                    for item in items {
                                        guard let itemContent = item["content"] as? [[String: Any]] else { continue }
                                        let parts = itemContent.compactMap { sub -> String? in
                                            guard let subType = sub["type"] as? String else { return nil }
                                            if subType == "paragraph", let inline = sub["inlineContent"] as? [[String: Any]] {
                                                let text = inline.map { item -> String in
                                                    let t = item["type"] as? String
                                                    if t == "codeVoice", let code = item["code"] as? String { return "`\(code)`" }
                                                    if (t == "strong" || t == "emphasis"), let inner = item["inlineContent"] as? [[String: Any]] {
                                                        return inner.map { innerItem -> String in
                                                            let innerType = innerItem["type"] as? String
                                                            if innerType == "codeVoice", let code = innerItem["code"] as? String { return "`\(code)`" }
                                                            return (innerItem["text"] as? String) ?? ""
                                                        }.joined()
                                                    }
                                                    return (item["text"] as? String) ?? ""
                                                }.joined().trimmingCharacters(in: .whitespacesAndNewlines)
                                                return text.isEmpty ? nil : text
                                            }
                                            if subType == "heading", let text = sub["text"] as? String {
                                                return text.trimmingCharacters(in: .whitespacesAndNewlines)
                                            }
                                            return nil
                                        }
                                        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                                        discussionBlocks.append("- \(text.isEmpty ? "_" : text)")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return DoccSymbolPage(
                identifier: identifierURL,
                title: title,
                abstract: abstractText.isEmpty ? nil : abstractText,
                discussion: discussionBlocks,
                symbolKind: symbolKind,
                roleHeading: roleHeading,
                moduleName: moduleName,
                topicSections: topicSections,
                relationshipSections: relationshipSections,
                declarations: declarations,
                referencesByIdentifier: referencesByIdentifier
            )
        }

        let decoder = JSONDecoder()
        var pagesByIdentifier: [String: DoccSymbolPage] = [:]

        for fileURL in documentationJSONFiles(in: bundleURL) {
            let data = try Data(contentsOf: fileURL)
            guard let probe = try? decoder.decode(KindProbe.self, from: data),
                  probe.kind == "symbol"
            else {
                continue
            }

            let node: RenderNode
            do {
                node = try decoder.decode(RenderNode.self, from: data)
            } catch {
                guard let page = decodeSymbolPageLossy(from: data, decoder: decoder) else { continue }
                pagesByIdentifier[page.identifier] = page
                continue
            }

            pagesByIdentifier[node.identifier.url] = makeSymbolPage(from: node)
        }

        return pagesByIdentifier
    }

    private func makeTutorialFileURL(for identifier: String, bundleURL: URL) -> URL {
        let root = bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("tutorials", isDirectory: true)

        if let url = URL(string: identifier), url.scheme == "doc" {
            var rawComponents = url.pathComponents.filter { $0 != "/" }
            if rawComponents.first == "tutorials" {
                rawComponents.removeFirst()
            }
            if !rawComponents.isEmpty {
                var directory = root
                for component in rawComponents.dropLast() {
                    directory = directory.appendingPathComponent(slug(for: component, fallback: "segment"), isDirectory: true)
                }
                let fileName = slug(for: rawComponents.last ?? "tutorial", fallback: "tutorial")
                return directory.appendingPathComponent(fileName).appendingPathExtension("json")
            }
        }

        let fallbackComponent = identifier.split(separator: "/").last.map(String.init) ?? identifier
        let fileName = slug(for: fallbackComponent, fallback: "tutorial")
        return root.appendingPathComponent(fileName).appendingPathExtension("json")
    }

    private func makeArticleFileURL(for identifier: String, bundleURL: URL) -> URL {
        let root = bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("documentation", isDirectory: true)
            .appendingPathComponent("articles", isDirectory: true)

        if let url = URL(string: identifier), url.scheme == "doc" {
            var rawComponents = url.pathComponents.filter { $0 != "/" }
            if rawComponents.first == "documentation" {
                rawComponents.removeFirst()
            }
            if !rawComponents.isEmpty {
                var directory = root
                for component in rawComponents.dropLast() {
                    directory = directory.appendingPathComponent(slug(for: component, fallback: "segment"), isDirectory: true)
                }
                let fileName = slug(for: rawComponents.last ?? "article", fallback: "article")
                return directory.appendingPathComponent(fileName).appendingPathExtension("json")
            }
        }

        let fallbackComponent = identifier.split(separator: "/").last.map(String.init) ?? identifier
        let fileName = slug(for: fallbackComponent, fallback: "article")
        return root.appendingPathComponent(fileName).appendingPathExtension("json")
    }

    private func slug(for value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = trimmed.lowercased()
        var scalars: [Character] = []
        var previousWasDash = false
        for scalar in lowercased.unicodeScalars {
            if CharacterSet.alphanumerics.contains(scalar) {
                scalars.append(Character(scalar))
                previousWasDash = false
            } else if !previousWasDash {
                scalars.append("-")
                previousWasDash = true
            }
        }
        var result = String(scalars).trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        if result.isEmpty {
            result = fallback
        }
        return result
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
