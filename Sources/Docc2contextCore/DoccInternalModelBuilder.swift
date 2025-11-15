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

public enum DoccInternalModelBuilderError: Error, Equatable {
    case notImplemented
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
        throw DoccInternalModelBuilderError.notImplemented
    }
}
