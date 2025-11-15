import XCTest

@testable import Docc2contextCore

final class DoccInternalModelSerializationTests: XCTestCase {
    func test_bundleModelIsCodable() throws {
        let catalog = DoccDocumentationCatalog(
            identifier: "com.example.docs",
            kind: "tutorialCollection",
            title: "Example Tutorials",
            role: nil,
            abstract: [],
            topics: [DoccDocumentationCatalog.TopicSection(
                title: "Chapter 1",
                identifiers: ["doc.chapter1"]
            )]
        )

        let model = DoccBundleModel(
            bundleMetadata: DoccBundleMetadata(
                identifier: "com.example.bundle",
                displayName: "Example",
                technologyRoot: "ExampleTech",
                locales: ["en"],
                doccVersion: "1.0",
                projectVersion: "1.0.0"
            ),
            renderMetadata: DoccRenderMetadata(
                formatVersion: "1.0",
                generatedAt: "2025-11-15T00:00:00Z",
                generator: "docc",
                kind: "tutorialCollection"
            ),
            bundleDataMetadata: DoccBundleDataMetadata(
                formatVersion: "1.0",
                generatedAt: Date(timeIntervalSince1970: 0),
                generator: "docc",
                kind: "tutorial"
            ),
            documentationCatalog: catalog,
            tutorialVolumes: [DoccTutorialVolume(
                identifier: catalog.identifier,
                title: catalog.title,
                chapters: [DoccTutorialChapter(
                    title: "Chapter 1",
                    pageIdentifiers: catalog.topics.first?.identifiers ?? []
                )]
            )],
            symbolReferences: []
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(model)
        XCTAssertFalse(data.isEmpty)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decoded = try decoder.decode(DoccBundleModel.self, from: data)
        XCTAssertEqual(decoded, model)
    }
}
