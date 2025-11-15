import Foundation

public struct DoccBundleModel: Equatable {
    public let bundleMetadata: DoccBundleMetadata
    public let renderMetadata: DoccRenderMetadata
    public let bundleDataMetadata: DoccBundleDataMetadata
    public let documentationCatalog: DoccDocumentationCatalog
    public let tutorialVolumes: [DoccTutorialVolume]
    public let symbolReferences: [DoccSymbolReference]

    public init(
        bundleMetadata: DoccBundleMetadata,
        renderMetadata: DoccRenderMetadata,
        bundleDataMetadata: DoccBundleDataMetadata,
        documentationCatalog: DoccDocumentationCatalog,
        tutorialVolumes: [DoccTutorialVolume],
        symbolReferences: [DoccSymbolReference]
    ) {
        self.bundleMetadata = bundleMetadata
        self.renderMetadata = renderMetadata
        self.bundleDataMetadata = bundleDataMetadata
        self.documentationCatalog = documentationCatalog
        self.tutorialVolumes = tutorialVolumes
        self.symbolReferences = symbolReferences
    }
}

public struct DoccTutorialVolume: Equatable {
    public let identifier: String
    public let title: String
    public let chapters: [DoccTutorialChapter]

    public init(identifier: String, title: String, chapters: [DoccTutorialChapter]) {
        self.identifier = identifier
        self.title = title
        self.chapters = chapters
    }
}

public struct DoccTutorialChapter: Equatable {
    public let title: String
    public let pageIdentifiers: [String]

    public init(title: String, pageIdentifiers: [String]) {
        self.title = title
        self.pageIdentifiers = pageIdentifiers
    }
}

public struct DoccInternalModelBuilder {
    public init() {}

    public func makeBundleModel(
        bundleMetadata: DoccBundleMetadata,
        renderMetadata: DoccRenderMetadata,
        documentationCatalog: DoccDocumentationCatalog,
        bundleDataMetadata: DoccBundleDataMetadata,
        symbolReferences: [DoccSymbolReference]
    ) throws -> DoccBundleModel {
        let tutorialVolumes = makeTutorialVolumes(from: documentationCatalog)

        return DoccBundleModel(
            bundleMetadata: bundleMetadata,
            renderMetadata: renderMetadata,
            bundleDataMetadata: bundleDataMetadata,
            documentationCatalog: documentationCatalog,
            tutorialVolumes: tutorialVolumes,
            symbolReferences: symbolReferences
        )
    }

    private func makeTutorialVolumes(
        from documentationCatalog: DoccDocumentationCatalog
    ) -> [DoccTutorialVolume] {
        guard shouldTreatAsTutorialCollection(documentationCatalog) else {
            return []
        }

        let chapters = documentationCatalog.topics.map { topic -> DoccTutorialChapter in
            let identifiers = topic.identifiers
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            return DoccTutorialChapter(title: topic.title, pageIdentifiers: identifiers)
        }

        let volume = DoccTutorialVolume(
            identifier: documentationCatalog.identifier,
            title: documentationCatalog.title,
            chapters: chapters
        )

        return [volume]
    }

    private func shouldTreatAsTutorialCollection(
        _ documentationCatalog: DoccDocumentationCatalog
    ) -> Bool {
        guard let role = documentationCatalog.role else { return false }
        return role.caseInsensitiveCompare("tutorialCollection") == .orderedSame
    }
}
