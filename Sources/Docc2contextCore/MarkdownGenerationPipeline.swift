import Foundation

/// Converts a DocC bundle into deterministic Markdown and a link graph.
///
/// Use this type when you want a **repeatable**, filesystem-based export that is suitable for feeding into
/// downstream tooling (for example, LLM context ingestion) without requiring Xcode.
///
/// The pipeline is designed to be:
/// - **Deterministic**: identical inputs produce byte-identical outputs (ordering, formatting, hashing).
/// - **Offline-friendly**: no network access is required during conversion.
/// - **Fixture-first**: the repo ships DocC fixtures under `Fixtures/` that are used by snapshot tests.
///
/// ## Usage
/// Convert a DocC archive directory to Markdown:
/// ```swift
/// let pipeline = MarkdownGenerationPipeline()
/// let summary = try pipeline.generateMarkdown(
///   from: "/path/to/MyLibrary.doccarchive",
///   to: "/tmp/docc2context-out",
///   forceOverwrite: true,
///   symbolLayout: .single
/// )
/// print(summary.symbolCount)
/// ```
public struct MarkdownGenerationPipeline {
    public struct Summary: Equatable, Codable {
        public let outputDirectory: URL
        public let tutorialVolumeCount: Int
        public let chapterCount: Int
        public let referenceArticleCount: Int
        public let symbolCount: Int

        public init(
            outputDirectory: URL,
            tutorialVolumeCount: Int,
            chapterCount: Int,
            referenceArticleCount: Int,
            symbolCount: Int = 0
        ) {
            self.outputDirectory = outputDirectory
            self.tutorialVolumeCount = tutorialVolumeCount
            self.chapterCount = chapterCount
            self.referenceArticleCount = referenceArticleCount
            self.symbolCount = symbolCount
        }
    }

    public enum SymbolLayout: String, CaseIterable, Codable {
        case tree
        case single
    }

    public enum Error: Swift.Error, LocalizedError {
        case inputDoesNotExist(URL)
        case inputIsNotDirectory(URL)
        case outputDirectoryOverlapsInput(URL)
        case outputDirectoryAlreadyExists(URL)
        case failedToRemoveExistingOutput(URL, Swift.Error)
        case failedToCreateOutput(URL, Swift.Error)
        case failedToWriteFile(URL, Swift.Error)

        public var errorDescription: String? {
            switch self {
            case .inputDoesNotExist(let url):
                return "Input path does not exist at \(url.path)."
            case .inputIsNotDirectory(let url):
                return "Input path must be a directory containing a DocC bundle: \(url.path)."
            case .outputDirectoryOverlapsInput(let url):
                return "Output directory overlaps the input bundle at \(url.path). Choose a different output path to avoid deleting the source when using --force."
            case .outputDirectoryAlreadyExists(let url):
                return "Output directory already exists at \(url.path). Pass --force to overwrite it."
            case .failedToRemoveExistingOutput(let url, let underlying):
                return "Failed to remove existing output directory at \(url.path): \(underlying.localizedDescription)"
            case .failedToCreateOutput(let url, let underlying):
                return "Failed to create output directory at \(url.path): \(underlying.localizedDescription)"
            case .failedToWriteFile(let url, let underlying):
                return "Failed to write Markdown file at \(url.path): \(underlying.localizedDescription)"
            }
        }
    }

    private let fileManager: FileManager
    private let metadataParser: DoccMetadataParser
    private let modelBuilder: DoccInternalModelBuilder
    private let renderer: DoccMarkdownRenderer
    private let linkGraphBuilder: LinkGraphBuilder
    private let markdownWriter: (String, URL) throws -> Void
    private let dataWriter: (Data, URL) throws -> Void

    public init(
        fileManager: FileManager = .default,
        metadataParser: DoccMetadataParser = .init(),
        modelBuilder: DoccInternalModelBuilder = .init(),
        renderer: DoccMarkdownRenderer = .init(),
        linkGraphBuilder: LinkGraphBuilder = .init(),
        markdownWriter: ((String, URL) throws -> Void)? = nil,
        dataWriter: ((Data, URL) throws -> Void)? = nil
    ) {
        self.fileManager = fileManager
        self.metadataParser = metadataParser
        self.modelBuilder = modelBuilder
        self.renderer = renderer
        self.linkGraphBuilder = linkGraphBuilder

        let ensureDirectory: (URL) throws -> Void = { directory in
            if fileManager.fileExists(atPath: directory.path) { return }
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                throw Error.failedToCreateOutput(directory, error)
            }
        }

        self.markdownWriter = markdownWriter ?? { markdown, url in
            let directory = url.deletingLastPathComponent()
            try ensureDirectory(directory)
            do {
                try markdown.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                throw Error.failedToWriteFile(url, error)
            }
        }

        self.dataWriter = dataWriter ?? { data, url in
            let directory = url.deletingLastPathComponent()
            try ensureDirectory(directory)
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                throw Error.failedToWriteFile(url, error)
            }
        }
    }

    public func generateMarkdown(
        from inputPath: String,
        to outputPath: String,
        forceOverwrite: Bool,
        technologyFilter: [String]? = nil,
        symbolLayout: SymbolLayout = .tree
    ) throws -> Summary {
        let inputURL = URL(fileURLWithPath: inputPath).standardizedFileURL
        try validateInputDirectory(inputURL)

        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true).standardizedFileURL
        try validateOutputPathDoesNotOverlapInput(inputURL: inputURL, outputURL: outputURL)
        try prepareOutputDirectory(at: outputURL, forceOverwrite: forceOverwrite)

        let bundleMetadata = try metadataParser.loadInfoPlist(from: inputURL)
        let renderMetadata = try metadataParser.loadRenderMetadata(from: inputURL)
        let documentationCatalog = try metadataParser.loadDocumentationCatalog(
            from: inputURL,
            technologyRoot: bundleMetadata.technologyRoot)
        let bundleDataMetadata = try metadataParser.loadBundleDataMetadata(from: inputURL)
        var symbolReferences = try metadataParser.loadSymbolGraphReferences(from: inputURL)

        // F2: Apply technology filter to symbol references
        if let filterSet = normalizedTechnologyFilterSet(technologyFilter) {
            symbolReferences = symbolReferences.filter { filterSet.contains($0.moduleName.lowercased()) }
        }

        let bundleModel = try modelBuilder.makeBundleModel(
            bundleMetadata: bundleMetadata,
            renderMetadata: renderMetadata,
            documentationCatalog: documentationCatalog,
            bundleDataMetadata: bundleDataMetadata,
            symbolReferences: symbolReferences)

        let markdownRoot = outputURL.appendingPathComponent("markdown", isDirectory: true)
        try ensureDirectoryExists(markdownRoot)

        var tutorialVolumeCount = 0
        var chapterCount = 0

        if !bundleModel.tutorialVolumes.isEmpty {
            let tutorialsRoot = markdownRoot.appendingPathComponent("tutorials", isDirectory: true)
            try ensureDirectoryExists(tutorialsRoot)

            for volume in bundleModel.tutorialVolumes where shouldRender(volume: volume) {
                tutorialVolumeCount += 1
                let volumeDirectory = tutorialsRoot.appendingPathComponent(
                    slug(for: volume.identifier, fallback: "volume"),
                    isDirectory: true)
                try ensureDirectoryExists(volumeDirectory)

                let overviewMarkdown = renderer.renderTutorialVolumeOverview(
                    catalog: bundleModel.documentationCatalog,
                    volume: volume)
                let overviewURL = volumeDirectory.appendingPathComponent("index.md", isDirectory: false)
                try write(markdown: overviewMarkdown, to: overviewURL)

                for (index, chapter) in volume.chapters.enumerated() {
                    let tutorialIdentifiers = chapter.pageIdentifiers.filter(isTutorialIdentifier(_:))
                    guard !tutorialIdentifiers.isEmpty else { continue }

                    var tutorials: [DoccTutorial] = []
                    tutorials.reserveCapacity(tutorialIdentifiers.count)
                    for identifier in tutorialIdentifiers {
                        do {
                            tutorials.append(try metadataParser.loadTutorialPage(withIdentifier: identifier, from: inputURL))
                        } catch {
                            let message =
                                "MarkdownGenerationPipeline: warning: failed to load tutorial page \(identifier): \(error)\n"
                            if let data = message.data(using: .utf8) {
                                FileHandle.standardError.write(data)
                            }
                        }
                    }

                    let chapterMarkdown = renderer.renderTutorialChapterPage(
                        catalog: bundleModel.documentationCatalog,
                        volume: volume,
                        chapter: chapter,
                        tutorials: tutorials)

                    let chapterURL = makeChapterFileURL(
                        title: chapter.title,
                        index: index,
                        under: volumeDirectory)
                    try write(markdown: chapterMarkdown, to: chapterURL)
                    chapterCount += 1
                }
            }
        }

        let articlesRoot = markdownRoot.appendingPathComponent("articles", isDirectory: true)
        var referenceArticleCount = 0
        // Streaming optimization: Load articles as dictionary to avoid intermediate array.
        let articlesByIdentifier = try loadAvailableArticlesDictionary(from: inputURL)
        let articleIdentifiers = orderedArticleIdentifiers(
            from: bundleModel.documentationCatalog,
            availableArticles: Set(articlesByIdentifier.keys))

        let renderArchiveSymbols = try metadataParser.loadSwiftDocCRenderArchiveSymbolPages(from: inputURL)

        if !articleIdentifiers.isEmpty && !articlesByIdentifier.isEmpty {
            try ensureDirectoryExists(articlesRoot)
        }

        for identifier in articleIdentifiers {
            guard let article = articlesByIdentifier[identifier] else { continue }
            let renderedArticle = maybeAugmentCollectionGroupArticle(
                article,
                symbolsByIdentifier: renderArchiveSymbols
            )
            let markdown = renderer.renderReferenceArticle(
                catalog: bundleModel.documentationCatalog,
                article: renderedArticle)
            let articleURL = makeArticleFileURL(for: identifier, under: articlesRoot)
            try write(markdown: markdown, to: articleURL)
            referenceArticleCount += 1
        }

        // Swift-DocC render archive symbol pages (F5): render `kind: "symbol"` nodes into Xcode-like Markdown.
        if !renderArchiveSymbols.isEmpty {
            switch symbolLayout {
            case .tree:
                for identifier in renderArchiveSymbols.keys.sorted() {
                    guard let symbol = renderArchiveSymbols[identifier] else { continue }
                    let markdown = renderer.renderSymbolPage(catalog: bundleModel.documentationCatalog, symbol: symbol)
                    let symbolURL = makeRenderNodeIndexFileURL(for: identifier, under: markdownRoot)
                    try write(markdown: markdown, to: symbolURL)
                }
            case .single:
                for identifier in renderArchiveSymbols.keys.sorted() {
                    guard isTopLevelSymbolIdentifier(identifier) else { continue }
                    guard let symbol = renderArchiveSymbols[identifier] else { continue }
                    let markdown = renderer.renderSymbolPage(catalog: bundleModel.documentationCatalog, symbol: symbol)
                    let symbolURL = makeRenderNodeSingleFileURL(for: identifier, under: markdownRoot)
                    try write(markdown: markdown, to: symbolURL)
                }
            }
        }

        // Build and write link graph
        let linkGraph = try linkGraphBuilder.buildLinkGraph(from: bundleModel)
        let linkGraphRoot = outputURL.appendingPathComponent("linkgraph", isDirectory: true)
        try ensureDirectoryExists(linkGraphRoot)
        let linkGraphURL = linkGraphRoot.appendingPathComponent("adjacency.json", isDirectory: false)
        let encoder = DeterministicJSONEncoder.makeEncoder()
        let linkGraphData = try encoder.encode(linkGraph)
        try write(data: linkGraphData, to: linkGraphURL)

        return Summary(
            outputDirectory: outputURL,
            tutorialVolumeCount: tutorialVolumeCount,
            chapterCount: chapterCount,
            referenceArticleCount: referenceArticleCount,
            symbolCount: symbolReferences.count)
    }

    private func normalizedTechnologyFilterSet(_ filters: [String]?) -> Set<String>? {
        guard let filters else { return nil }
        let normalizedFilters = filters
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        guard !normalizedFilters.isEmpty else { return nil }
        return Set(normalizedFilters)
    }

    private func validateInputDirectory(_ url: URL) throws {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            throw Error.inputDoesNotExist(url)
        }
        guard isDirectory.boolValue else {
            throw Error.inputIsNotDirectory(url)
        }
    }

    private func validateOutputPathDoesNotOverlapInput(inputURL: URL, outputURL: URL) throws {
        let inputComponents = inputURL.pathComponents
        let outputComponents = outputURL.pathComponents

        if outputComponents == inputComponents ||
            outputComponents.starts(with: inputComponents) ||
            inputComponents.starts(with: outputComponents) {
            throw Error.outputDirectoryOverlapsInput(outputURL)
        }
    }

    private func prepareOutputDirectory(at url: URL, forceOverwrite: Bool) throws {
        if fileManager.fileExists(atPath: url.path) {
            guard forceOverwrite else {
                throw Error.outputDirectoryAlreadyExists(url)
            }
            do {
                try fileManager.removeItem(at: url)
            } catch {
                throw Error.failedToRemoveExistingOutput(url, error)
            }
        }

        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            throw Error.failedToCreateOutput(url, error)
        }
    }

    private func ensureDirectoryExists(_ url: URL) throws {
        if fileManager.fileExists(atPath: url.path) { return }
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            throw Error.failedToCreateOutput(url, error)
        }
    }

    private func write(markdown: String, to url: URL) throws {
        do {
            try markdownWriter(markdown, url)
        } catch let pipelineError as Error {
            throw pipelineError
        } catch {
            throw Error.failedToWriteFile(url, error)
        }
    }

    private func write(data: Data, to url: URL) throws {
        do {
            try dataWriter(data, url)
        } catch let pipelineError as Error {
            throw pipelineError
        } catch {
            throw Error.failedToWriteFile(url, error)
        }
    }

    private func shouldRender(volume: DoccTutorialVolume) -> Bool {
        for chapter in volume.chapters {
            if chapter.pageIdentifiers.contains(where: isTutorialIdentifier(_:)) {
                return true
            }
        }
        return false
    }

    private func isTutorialIdentifier(_ identifier: String) -> Bool {
        identifier.contains("/tutorials/")
    }

    private func orderedArticleIdentifiers(
        from catalog: DoccDocumentationCatalog,
        availableArticles: Set<String>
    ) -> [String] {
        var seen: Set<String> = []
        var identifiers: [String] = []
        for topic in catalog.topics {
            for identifier in topic.identifiers {
                guard availableArticles.contains(identifier) else { continue }
                if seen.insert(identifier).inserted {
                    identifiers.append(identifier)
                }
            }
        }

        if seen.count != availableArticles.count {
            let remaining = availableArticles
                .subtracting(seen)
                .sorted()
            identifiers.append(contentsOf: remaining)
        }

        return identifiers
    }

    func makeChapterFileURL(title: String, index: Int, under volumeDirectory: URL) -> URL {
        let numberedTitle = "\(index + 1)-\(title)"
        let slugValue = slug(for: numberedTitle, fallback: "chapter-\(index + 1)")
        return volumeDirectory.appendingPathComponent("\(slugValue).md", isDirectory: false)
    }

    private func makeArticleFileURL(for identifier: String, under root: URL) -> URL {
        let rawComponents: [String]
        if let url = URL(string: identifier), url.scheme == "doc" {
            rawComponents = url.pathComponents.filter { $0 != "/" }
        } else {
            rawComponents = identifier.split(separator: "/").map(String.init)
        }

        var components = rawComponents.map { slug(for: String($0), fallback: "segment") }
        guard let fileName = components.popLast() else {
            return root.appendingPathComponent("article.md", isDirectory: false)
        }
        var directory = root
        for component in components {
            directory = directory.appendingPathComponent(component, isDirectory: true)
        }
        return directory.appendingPathComponent(fileName).appendingPathExtension("md")
    }

    private func makeRenderNodeIndexFileURL(for identifier: String, under markdownRoot: URL) -> URL {
        guard let docURL = URL(string: identifier), docURL.scheme == "doc" else {
            return markdownRoot
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent(slug(for: identifier, fallback: "symbol"), isDirectory: true)
                .appendingPathComponent("index.md", isDirectory: false)
        }

        let rawComponents = docURL.pathComponents.filter { $0 != "/" }
        var directory = markdownRoot
        for component in rawComponents {
            directory = directory.appendingPathComponent(slug(for: component, fallback: "segment"), isDirectory: true)
        }
        return directory.appendingPathComponent("index.md", isDirectory: false)
    }

    private func isTopLevelSymbolIdentifier(_ identifier: String) -> Bool {
        guard let docURL = URL(string: identifier), docURL.scheme == "doc" else { return false }
        let rawComponents = docURL.pathComponents.filter { $0 != "/" }
        guard rawComponents.count == 3 else { return false }
        return rawComponents.first == "documentation"
    }

    private func makeRenderNodeSingleFileURL(for identifier: String, under markdownRoot: URL) -> URL {
        guard let docURL = URL(string: identifier), docURL.scheme == "doc" else {
            return markdownRoot
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent(slug(for: identifier, fallback: "symbol") + ".md", isDirectory: false)
        }

        let rawComponents = docURL.pathComponents.filter { $0 != "/" }
        guard rawComponents.count >= 2 else {
            return markdownRoot
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("symbol.md", isDirectory: false)
        }

        var directory = markdownRoot
        for component in rawComponents.dropLast() {
            directory = directory.appendingPathComponent(slug(for: component, fallback: "segment"), isDirectory: true)
        }

        let fileName = slug(for: rawComponents.last ?? "symbol", fallback: "symbol")
        return directory.appendingPathComponent(fileName).appendingPathExtension("md")
    }

    private func maybeAugmentCollectionGroupArticle(
        _ article: DoccArticle,
        symbolsByIdentifier: [String: DoccSymbolPage]
    ) -> DoccArticle {
        guard article.kind == "article",
              article.sections.isEmpty,
              let parentIdentifier = parentSymbolIdentifier(forCollectionGroupArticleIdentifier: article.identifier),
              let parentSymbol = symbolsByIdentifier[parentIdentifier]
        else {
            return article
        }

        var contextLines: [String] = []
        if let summary = parentSymbol.abstract?.trimmingCharacters(in: .whitespacesAndNewlines), !summary.isEmpty {
            contextLines.append(summary)
        }

        let discussionText = parentSymbol.discussion
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if let firstParagraph = discussionText.first(where: { !$0.hasPrefix("#") }) {
            contextLines.append(firstParagraph)
        }

        guard !contextLines.isEmpty else { return article }

        let augmentedSections = [DoccArticle.Section(title: "Context", content: contextLines)]
        return DoccArticle(
            identifier: article.identifier,
            kind: article.kind,
            title: article.title,
            abstract: article.abstract,
            sections: augmentedSections + article.sections,
            topics: article.topics,
            references: article.references
        )
    }

    private func parentSymbolIdentifier(forCollectionGroupArticleIdentifier identifier: String) -> String? {
        guard let url = URL(string: identifier), url.scheme == "doc", let host = url.host else { return nil }
        let components = url.pathComponents.filter { $0 != "/" }
        guard components.count >= 4 else { return nil }
        guard components.first == "documentation" else { return nil }
        // documentation/<module>/<symbol>/<collection-group>
        let module = components[1]
        let symbol = components[2]
        return "doc://\(host)/documentation/\(module)/\(symbol)"
    }

    /// Streaming-optimized article loading: Returns dictionary directly without intermediate array
    ///
    /// This optimization reduces memory overhead by avoiding the intermediate array allocation
    /// and subsequent dictionary conversion. For large DocC bundles with many articles,
    /// this can significantly reduce peak memory usage.
    ///
    /// - Parameter bundleURL: URL to the DocC bundle
    /// - Returns: Dictionary mapping article identifiers to DoccArticle instances
    private func loadAvailableArticlesDictionary(from bundleURL: URL) throws -> [String: DoccArticle] {
        let documentationRoot = bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("documentation", isDirectory: true)

        guard fileManager.fileExists(atPath: documentationRoot.path) else {
            return [:]
        }

        let enumerator = fileManager.enumerator(
            at: documentationRoot,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles])

        let fileURLs = (enumerator?.allObjects as? [URL] ?? [])
            .filter { $0.pathExtension.lowercased() == "json" }
            .sorted { $0.path < $1.path }

        struct KindProbe: Decodable { let kind: String }

        var articlesByIdentifier: [String: DoccArticle] = [:]
        articlesByIdentifier.reserveCapacity(16)

        let decoder = JSONDecoder()
        for fileURL in fileURLs {
            let data = try Data(contentsOf: fileURL)

            guard let probe = try? decoder.decode(KindProbe.self, from: data),
                  probe.kind == "article"
            else {
                continue
            }

            do {
                let article = try decoder.decode(DoccArticle.self, from: data)
                articlesByIdentifier[article.identifier] = article
            } catch {
                throw DoccMetadataParserError.invalidArticlePage(fileURL)
            }
        }

        return articlesByIdentifier
    }

    private func slug(for value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = trimmed.lowercased()
        var scalars: [Character] = []
        var previousWasDash = false
        for scalar in lowercased.unicodeScalars {
            if CharacterSet.alphanumerics.contains(scalar) {
                let character = Character(scalar)
                scalars.append(character)
                previousWasDash = false
            } else {
                if !previousWasDash {
                    scalars.append("-")
                    previousWasDash = true
                }
            }
        }
        var slug = String(scalars).trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        if slug.isEmpty {
            slug = fallback
        }
        return slug
    }
}
