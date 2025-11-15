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

        let encoder = DeterministicJSONEncoder.makeEncoder()
        let data = try encoder.encode(model)
        XCTAssertFalse(data.isEmpty)

        let decoder = DeterministicJSONEncoder.makeDecoder()
        let decoded = try decoder.decode(DoccBundleModel.self, from: data)
        XCTAssertEqual(decoded, model)
    }

    func test_tutorialCatalogSerializationMatchesSnapshot() throws {
        let model = try makeTutorialCatalogBundleModel()
        let encoder = DeterministicJSONEncoder.makeEncoder()
        let data = try encoder.encode(model)

        let decoder = DeterministicJSONEncoder.makeDecoder()
        let decoded = try decoder.decode(DoccBundleModel.self, from: data)
        XCTAssertEqual(decoded, model)

        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        try JSONSnapshot.assertSnapshot(
            self,
            matching: json,
            named: "tutorial-catalog",
            record: SnapshotRecording.isEnabled
        )
    }

    func test_encoderProducesStableDataForTutorialCatalog() throws {
        let model = try makeTutorialCatalogBundleModel()
        let encoder = DeterministicJSONEncoder.makeEncoder()

        let first = try encoder.encode(model)
        let second = try encoder.encode(model)
        XCTAssertEqual(first, second)
    }

    private func makeTutorialCatalogBundleModel() throws -> DoccBundleModel {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let parser = DoccMetadataParser()

        let bundleMetadata = try parser.loadInfoPlist(from: fixturesURL)
        let renderMetadata = try parser.loadRenderMetadata(from: fixturesURL)
        let documentationCatalog = try parser.loadDocumentationCatalog(
            from: fixturesURL,
            technologyRoot: bundleMetadata.technologyRoot)
        let bundleDataMetadata = try parser.loadBundleDataMetadata(from: fixturesURL)
        let symbolReferences = try parser.loadSymbolGraphReferences(from: fixturesURL)

        let builder = DoccInternalModelBuilder()
        return try builder.makeBundleModel(
            bundleMetadata: bundleMetadata,
            renderMetadata: renderMetadata,
            documentationCatalog: documentationCatalog,
            bundleDataMetadata: bundleDataMetadata,
            symbolReferences: symbolReferences)
    }
}
