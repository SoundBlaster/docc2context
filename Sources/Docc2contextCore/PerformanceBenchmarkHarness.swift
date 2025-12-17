import Foundation

public struct BenchmarkFixtureBuilder {
    private let fileManager: FileManager
    private let metadataParser: DoccMetadataParser
    private static let payloadSeed = "Benchmark payload text for docc2context performance harness. "

    public init(
        fileManager: FileManager = .default,
        metadataParser: DoccMetadataParser = .init()
    ) {
        self.fileManager = fileManager
        self.metadataParser = metadataParser
    }

    /// Synthesize a benchmark-friendly DocC bundle by copying the base fixture and
    /// expanding its article content until the target size is reached.
    ///
    /// The generated bundle remains deterministic by reusing the base fixture
    /// structure and seeding the additional article with fixed content. Existing
    /// fixtures remain untouched on disk.
    ///
    /// - Parameters:
    ///   - baseFixtureURL: Path to an existing DocC bundle that will be copied.
    ///   - targetSizeBytes: Desired minimum size of the resulting bundle.
    ///   - destinationDirectory: Directory that will contain the synthesized bundle.
    /// - Returns: URL to the synthesized `.doccarchive`.
    public func synthesizeBenchmarkFixture(
        baseFixtureURL: URL,
        targetSizeBytes: Int,
        destinationDirectory: URL
    ) throws -> URL {
        let bundleName = baseFixtureURL.deletingPathExtension().lastPathComponent
        let outputURL = destinationDirectory
            .appendingPathComponent("\(bundleName)-Benchmark.doccarchive", isDirectory: true)

        if fileManager.fileExists(atPath: outputURL.path) {
            try fileManager.removeItem(at: outputURL)
        }
        try fileManager.copyItem(at: baseFixtureURL, to: outputURL)

        let currentSize = try Self.directorySize(at: outputURL)
        guard targetSizeBytes > currentSize else { return outputURL }

        let bundleMetadata = try metadataParser.loadInfoPlist(from: outputURL)
        let documentationCatalog = try metadataParser.loadDocumentationCatalog(
            from: outputURL,
            technologyRoot: bundleMetadata.technologyRoot)

        let articlesDirectory = outputURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("documentation", isDirectory: true)
            .appendingPathComponent("articles", isDirectory: true)
        if !fileManager.fileExists(atPath: articlesDirectory.path) {
            try fileManager.createDirectory(at: articlesDirectory, withIntermediateDirectories: true)
        }

        let baseArticleTemplate = try loadTemplateArticle(from: articlesDirectory)
        let payloadBytes = max(1024, targetSizeBytes - currentSize)
        let payloadIdentifier = "\(bundleMetadata.technologyRoot)/documentation/articles/benchmark-payload"
        let payloadArticle = makePayloadArticle(
            identifier: payloadIdentifier,
            payloadBytes: payloadBytes,
            template: baseArticleTemplate)

        let encoder = DeterministicJSONEncoder.makeEncoder()
        let payloadURL = articlesDirectory.appendingPathComponent("benchmark-payload.json")
        let payloadData = try encoder.encode(payloadArticle)
        try payloadData.write(to: payloadURL)

        var updatedTopics = documentationCatalog.topics
        let identifierAlreadyPresent = updatedTopics
            .flatMap { $0.identifiers }
            .contains(payloadIdentifier)
        if !identifierAlreadyPresent {
            let payloadTopic = DoccDocumentationCatalog.TopicSection(
                title: "Benchmark Payload",
                identifiers: [payloadIdentifier])
            updatedTopics.append(payloadTopic)
        }

        let updatedCatalog = DoccDocumentationCatalog(
            identifier: documentationCatalog.identifier,
            kind: documentationCatalog.kind,
            title: documentationCatalog.title,
            role: documentationCatalog.role,
            abstract: documentationCatalog.abstract,
            topics: updatedTopics)

        let catalogURL = outputURL
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("documentation", isDirectory: true)
            .appendingPathComponent("\(bundleMetadata.technologyRoot).json", isDirectory: false)
        let catalogData = try encoder.encode(updatedCatalog)
        try catalogData.write(to: catalogURL)

        return outputURL
    }

    private func loadTemplateArticle(from articlesDirectory: URL) throws -> DoccArticle {
        let articleFiles = try fileManager.contentsOfDirectory(
            at: articlesDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles])
            .filter { $0.pathExtension.lowercased() == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        guard let firstArticle = articleFiles.first else {
            throw DoccMetadataParserError.invalidArticlePage(articlesDirectory)
        }

        let data = try Data(contentsOf: firstArticle)
        let decoder = JSONDecoder()
        return try decoder.decode(DoccArticle.self, from: data)
    }

    private func makePayloadArticle(
        identifier: String,
        payloadBytes: Int,
        template: DoccArticle
    ) -> DoccArticle {
        let sections = makePayloadSections(totalBytes: payloadBytes)

        let abstract: [DoccArticle.AbstractItem]
        if template.abstract.isEmpty {
            abstract = [DoccArticle.AbstractItem(
                type: "text",
                text: "Synthetic payload article for performance benchmarking.")]
        } else {
            abstract = template.abstract
        }

        return DoccArticle(
            identifier: identifier,
            kind: template.kind,
            title: "Performance Benchmark Payload",
            abstract: abstract,
            sections: sections,
            topics: [],
            references: template.references)
    }

    private func makePayloadSections(totalBytes: Int) -> [DoccArticle.Section] {
        let segments = max(1, min(3, totalBytes / 1024))
        let baseTextData = Self.payloadSeed.data(using: .utf8) ?? Data()
        var remaining = totalBytes
        var sections: [DoccArticle.Section] = []

        for index in 0..<segments {
            let targetBytes = max(512, remaining / (segments - index))
            let content = makePayloadString(targetBytes: targetBytes, seed: baseTextData)
            remaining -= targetBytes
            let section = DoccArticle.Section(
                title: "Benchmark Section \(index + 1)",
                content: [content])
            sections.append(section)
        }

        return sections
    }

    private func makePayloadString(targetBytes: Int, seed: Data) -> String {
        guard !seed.isEmpty else {
            return String(repeating: "benchmark", count: targetBytes / 8)
        }

        var data = Data(capacity: targetBytes)
        while data.count < targetBytes {
            data.append(seed)
        }
        if data.count > targetBytes {
            data = data.prefix(targetBytes)
        }
        return String(data: data, encoding: .utf8) ?? Self.payloadSeed
    }

    /// Return total size of files contained under the given directory.
    public static func directorySize(at url: URL) throws -> Int {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileSizeKey]) else {
            return 0
        }

        var total = 0
        for case let fileURL as URL in enumerator {
            let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .totalFileAllocatedSizeKey, .fileSizeKey])
            guard resourceValues.isRegularFile == true else { continue }
            if let allocated = resourceValues.totalFileAllocatedSize {
                total += allocated
            } else if let fileSize = resourceValues.fileSize {
                total += fileSize
            }
        }
        return total
    }
}

public struct PerformanceBenchmarkHarness {
    public struct Configuration {
        public let fixtureURL: URL
        public let iterations: Int
        public let thresholdSeconds: TimeInterval
        public let outputDirectory: URL
        public let keepOutputs: Bool

        public init(
            fixtureURL: URL,
            iterations: Int,
            thresholdSeconds: TimeInterval,
            outputDirectory: URL,
            keepOutputs: Bool
        ) {
            self.fixtureURL = fixtureURL
            self.iterations = iterations
            self.thresholdSeconds = thresholdSeconds
            self.outputDirectory = outputDirectory
            self.keepOutputs = keepOutputs
        }
    }

    public struct Sample: Codable {
        public let iteration: Int
        public let durationSeconds: TimeInterval
        public let outputBytes: Int
        public let outputFileCount: Int
        public let summary: MarkdownGenerationPipeline.Summary
    }

    public struct Result {
        public let samples: [Sample]
        public let averageSeconds: TimeInterval
        public let maxSeconds: TimeInterval
        public let thresholdSeconds: TimeInterval
        public let passed: Bool
        public let outputRoot: URL

        public func makeMetrics(
            fixtureURL: URL,
            fixtureSizeBytes: Int
        ) -> BenchmarkMetrics {
            return BenchmarkMetrics(
                fixturePath: fixtureURL.path,
                fixtureSizeBytes: fixtureSizeBytes,
                thresholdSeconds: thresholdSeconds,
                averageSeconds: averageSeconds,
                maxSeconds: maxSeconds,
                passed: passed,
                samples: samples.map {
                    BenchmarkMetrics.SampleMetrics(
                        iteration: $0.iteration,
                        durationSeconds: $0.durationSeconds,
                        outputBytes: $0.outputBytes,
                        outputFileCount: $0.outputFileCount,
                        summary: $0.summary)
                })
        }
    }

    public struct BenchmarkMetrics: Codable {
        public struct SampleMetrics: Codable {
            public let iteration: Int
            public let durationSeconds: TimeInterval
            public let outputBytes: Int
            public let outputFileCount: Int
            public let summary: MarkdownGenerationPipeline.Summary
        }

        public let fixturePath: String
        public let fixtureSizeBytes: Int
        public let thresholdSeconds: TimeInterval
        public let averageSeconds: TimeInterval
        public let maxSeconds: TimeInterval
        public let passed: Bool
        public let samples: [SampleMetrics]
    }

    private let pipeline: MarkdownGenerationPipeline
    private let fileManager: FileManager

    public init(
        pipeline: MarkdownGenerationPipeline = .init(),
        fileManager: FileManager = .default
    ) {
        self.pipeline = pipeline
        self.fileManager = fileManager
    }

    public func run(configuration: Configuration) throws -> Result {
        if !fileManager.fileExists(atPath: configuration.outputDirectory.path) {
            try fileManager.createDirectory(at: configuration.outputDirectory, withIntermediateDirectories: true)
        }

        var samples: [Sample] = []
        var maxDuration: TimeInterval = 0
        var totalDuration: TimeInterval = 0

        for iteration in 1...max(1, configuration.iterations) {
            let iterationDirectory = configuration.outputDirectory.appendingPathComponent(
                "iteration-\(iteration)",
                isDirectory: true)
            if fileManager.fileExists(atPath: iterationDirectory.path) {
                try fileManager.removeItem(at: iterationDirectory)
            }
            try fileManager.createDirectory(at: iterationDirectory, withIntermediateDirectories: true)

            let start = Date()
            let summary = try pipeline.generateMarkdown(
                from: configuration.fixtureURL.path,
                to: iterationDirectory.path,
                forceOverwrite: true)
            let duration = Date().timeIntervalSince(start)

            let outputBytes = try BenchmarkFixtureBuilder.directorySize(at: iterationDirectory)
            let outputFileCount = try countFiles(at: iterationDirectory)

            let sample = Sample(
                iteration: iteration,
                durationSeconds: duration,
                outputBytes: outputBytes,
                outputFileCount: outputFileCount,
                summary: summary)
            samples.append(sample)

            totalDuration += duration
            maxDuration = max(maxDuration, duration)

            if !configuration.keepOutputs {
                try fileManager.removeItem(at: iterationDirectory)
            }
        }

        let average = samples.isEmpty ? 0 : totalDuration / Double(samples.count)
        let passed = maxDuration <= configuration.thresholdSeconds

        return Result(
            samples: samples,
            averageSeconds: average,
            maxSeconds: maxDuration,
            thresholdSeconds: configuration.thresholdSeconds,
            passed: passed,
            outputRoot: configuration.outputDirectory)
    }

    private func countFiles(at url: URL) throws -> Int {
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey]) else {
            return 0
        }
        var count = 0
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            if values.isRegularFile == true {
                count += 1
            }
        }
        return count
    }
}
