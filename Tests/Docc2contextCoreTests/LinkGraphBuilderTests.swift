import XCTest
@testable import Docc2contextCore

final class LinkGraphBuilderTests: XCTestCase {

    func test_buildLinkGraphFromTutorialCatalogFixture() throws {
        // Arrange
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let bundleModel = try loadBundleModel(from: tutorialFixture)
        let builder = LinkGraphBuilder()

        // Act
        let linkGraph = try builder.buildLinkGraph(from: bundleModel)

        // Assert
        XCTAssertFalse(linkGraph.adjacency.isEmpty, "Link graph should contain adjacency entries")
        XCTAssertFalse(linkGraph.allPageIdentifiers.isEmpty, "Link graph should contain page identifiers")
    }

    func test_buildLinkGraphFromArticleReferenceFixture() throws {
        // Arrange
        let articleFixture = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        let bundleModel = try loadBundleModel(from: articleFixture)
        let builder = LinkGraphBuilder()

        // Act
        let linkGraph = try builder.buildLinkGraph(from: bundleModel)

        // Assert
        XCTAssertFalse(linkGraph.adjacency.isEmpty, "Link graph should contain adjacency entries")
    }

    func test_linkGraphMatchesSnapshot() throws {
        // Arrange
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let bundleModel = try loadBundleModel(from: tutorialFixture)
        let builder = LinkGraphBuilder()

        // Act
        let linkGraph = try builder.buildLinkGraph(from: bundleModel)
        let encoder = DeterministicJSONEncoder.makeEncoder()
        let jsonData = try encoder.encode(linkGraph)
        let jsonString = try XCTUnwrap(String(data: jsonData, encoding: .utf8))

        // Assert
        try JSONSnapshot.assertSnapshot(
            self,
            matching: jsonString,
            named: "tutorialCatalogLinkGraph",
            record: SnapshotRecording.isEnabled)
    }

    func test_identifiesAllPageIdentifiersFromTutorials() throws {
        // Arrange
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let bundleModel = try loadBundleModel(from: tutorialFixture)
        let builder = LinkGraphBuilder()

        // Act
        let linkGraph = try builder.buildLinkGraph(from: bundleModel)

        // Assert
        // TutorialCatalog has a chapter with pageIdentifiers
        XCTAssertTrue(linkGraph.allPageIdentifiers.contains("tutorialcatalog/tutorials/getting-started"),
                      "Should extract tutorial page identifiers from chapters")
    }

    func test_identifiesArticleIdentifiers() throws {
        // Arrange
        let articleFixture = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        let bundleModel = try loadBundleModel(from: articleFixture)
        let builder = LinkGraphBuilder()

        // Act
        let linkGraph = try builder.buildLinkGraph(from: bundleModel)

        // Assert
        XCTAssertTrue(linkGraph.allPageIdentifiers.count > 0,
                      "Should extract article identifiers")
    }

    func test_linksAreOrderedDeterministically() throws {
        // Arrange
        let tutorialFixture = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let bundleModel = try loadBundleModel(from: tutorialFixture)
        let builder = LinkGraphBuilder()

        // Act
        let linkGraph1 = try builder.buildLinkGraph(from: bundleModel)
        let linkGraph2 = try builder.buildLinkGraph(from: bundleModel)

        // Assert - Both should have same keys in same order (deterministic)
        XCTAssertEqual(Array(linkGraph1.adjacency.keys).sorted(),
                      Array(linkGraph2.adjacency.keys).sorted(),
                      "Link graph should be deterministic")
    }

    func test_unresolvedReferencesAreCaptured() throws {
        // Arrange
        let articleFixture = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        let bundleModel = try loadBundleModel(from: articleFixture)
        let builder = LinkGraphBuilder()

        // Act
        let linkGraph = try builder.buildLinkGraph(from: bundleModel)

        // Assert
        XCTAssertNotNil(linkGraph.unresolvedReferences, "Should track unresolved references")
    }

    // MARK: - Helper Methods

    private func loadBundleModel(from url: Foundation.URL) throws -> DoccBundleModel {
        let parser = DoccMetadataParser()
        let builder = DoccInternalModelBuilder()

        let bundleMetadata = try parser.loadInfoPlist(from: url)
        let renderMetadata = try parser.loadRenderMetadata(from: url)
        let documentationCatalog = try parser.loadDocumentationCatalog(
            from: url,
            technologyRoot: bundleMetadata.technologyRoot)
        let bundleDataMetadata = try parser.loadBundleDataMetadata(from: url)
        let symbolReferences = try parser.loadSymbolGraphReferences(from: url)

        return try builder.makeBundleModel(
            bundleMetadata: bundleMetadata,
            renderMetadata: renderMetadata,
            documentationCatalog: documentationCatalog,
            bundleDataMetadata: bundleDataMetadata,
            symbolReferences: symbolReferences)
    }
}
