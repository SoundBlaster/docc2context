import Foundation

public struct MarkdownGenerationPipeline {
    public struct Summary: Equatable {
        public let outputDirectory: URL
        public let tutorialVolumeCount: Int
        public let chapterCount: Int
        public let referenceArticleCount: Int

        public init(
            outputDirectory: URL,
            tutorialVolumeCount: Int,
            chapterCount: Int,
            referenceArticleCount: Int
        ) {
            self.outputDirectory = outputDirectory
            self.tutorialVolumeCount = tutorialVolumeCount
            self.chapterCount = chapterCount
            self.referenceArticleCount = referenceArticleCount
        }
    }

    public enum Error: Swift.Error, LocalizedError {
        case inputDoesNotExist(URL)
        case inputIsNotDirectory(URL)
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
        forceOverwrite: Bool
    ) throws -> Summary {
        let inputURL = URL(fileURLWithPath: inputPath)
        try validateInputDirectory(inputURL)

        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)
        try prepareOutputDirectory(at: outputURL, forceOverwrite: forceOverwrite)

        let bundleMetadata = try metadataParser.loadInfoPlist(from: inputURL)
        let renderMetadata = try metadataParser.loadRenderMetadata(from: inputURL)
        let documentationCatalog = try metadataParser.loadDocumentationCatalog(
            from: inputURL,
            technologyRoot: bundleMetadata.technologyRoot)
        let bundleDataMetadata = try metadataParser.loadBundleDataMetadata(from: inputURL)
        let symbolReferences = try metadataParser.loadSymbolGraphReferences(from: inputURL)

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

                    let tutorials = try tutorialIdentifiers.map { identifier in
                        try metadataParser.loadTutorialPage(withIdentifier: identifier, from: inputURL)
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
        let articleIdentifiers = orderedArticleIdentifiers(from: bundleModel.documentationCatalog)
        let availableArticles = try loadAvailableArticles(from: inputURL)
        let articlesByIdentifier = Dictionary(uniqueKeysWithValues: availableArticles.map { ($0.identifier, $0) })
        if !articleIdentifiers.isEmpty && !articlesByIdentifier.isEmpty {
            try ensureDirectoryExists(articlesRoot)
        }

        for identifier in articleIdentifiers {
            guard let article = articlesByIdentifier[identifier] else { continue }
            let markdown = renderer.renderReferenceArticle(
                catalog: bundleModel.documentationCatalog,
                article: article)
            let articleURL = makeArticleFileURL(for: identifier, under: articlesRoot)
            try write(markdown: markdown, to: articleURL)
            referenceArticleCount += 1
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
            referenceArticleCount: referenceArticleCount)
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

    private func orderedArticleIdentifiers(from catalog: DoccDocumentationCatalog) -> [String] {
        var seen: Set<String> = []
        var identifiers: [String] = []
        for topic in catalog.topics {
            for identifier in topic.identifiers where identifier.contains("/articles/") {
                if seen.insert(identifier).inserted {
                    identifiers.append(identifier)
                }
            }
        }
        return identifiers
    }

    func makeChapterFileURL(title: String, index: Int, under volumeDirectory: URL) -> URL {
        let numberedTitle = "\(index + 1)-\(title)"
        let slugValue = slug(for: numberedTitle, fallback: "chapter-\(index + 1)")
        return volumeDirectory.appendingPathComponent("\(slugValue).md", isDirectory: false)
    }

    private func makeArticleFileURL(for identifier: String, under root: URL) -> URL {
        var components = identifier.split(separator: "/").map { slug(for: String($0), fallback: "segment") }
        guard let fileName = components.popLast() else {
            return root.appendingPathComponent("article.md", isDirectory: false)
        }
        var directory = root
        for component in components {
            directory = directory.appendingPathComponent(component, isDirectory: true)
        }
        return directory.appendingPathComponent(fileName).appendingPathExtension("md")
    }

    private func loadAvailableArticles(from bundleURL: URL) throws -> [DoccArticle] {
        let articlesDirectory = bundleURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("documentation", isDirectory: true)
            .appendingPathComponent("articles", isDirectory: true)

        guard fileManager.fileExists(atPath: articlesDirectory.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: articlesDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles])
            .filter { $0.pathExtension.lowercased() == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        var articles: [DoccArticle] = []
        let decoder = JSONDecoder()
        for fileURL in fileURLs {
            let data = try Data(contentsOf: fileURL)
            do {
                let article = try decoder.decode(DoccArticle.self, from: data)
                articles.append(article)
            } catch {
                throw DoccMetadataParserError.invalidArticlePage(fileURL)
            }
        }

        return articles
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
