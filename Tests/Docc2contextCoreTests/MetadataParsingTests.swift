import XCTest
@testable import Docc2contextCore

final class MetadataParsingTests: XCTestCase {
    func test_infoPlistLoadsBundleMetadata() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let parser = DoccMetadataParser()

        let metadata = try parser.loadInfoPlist(from: fixturesURL)

        XCTAssertEqual(metadata.identifier, "com.docc2context.tutorialcatalog")
        XCTAssertEqual(metadata.displayName, "DocC2Context Tutorial Catalog")
        XCTAssertEqual(metadata.technologyRoot, "tutorialcatalog")
        XCTAssertEqual(metadata.locales, ["en"])
        XCTAssertEqual(metadata.doccVersion, "1.0")
        XCTAssertEqual(metadata.projectVersion, "1.0")
    }

    func test_renderMetadataLoadsBundleInformation() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let parser = DoccMetadataParser()

        let metadata = try parser.loadRenderMetadata(from: fixturesURL)

        XCTAssertEqual(metadata.formatVersion, "1.0")
        XCTAssertEqual(metadata.generatedAt, "2025-11-14T00:00:00Z")
        XCTAssertEqual(metadata.generator, "docc2context synthetic fixture")
        XCTAssertEqual(metadata.kind, "tutorial")
    }

    func test_documentationCatalogLoadsTechnologyOverview() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let parser = DoccMetadataParser()

        let info = try parser.loadInfoPlist(from: fixturesURL)
        let catalog = try parser.loadDocumentationCatalog(from: fixturesURL,
                                                          technologyRoot: info.technologyRoot)

        XCTAssertEqual(catalog.identifier, "tutorialcatalog")
        XCTAssertEqual(catalog.kind, "technology")
        XCTAssertEqual(catalog.title, "DocC2Context Tutorial Catalog")
        XCTAssertEqual(catalog.role, "tutorialCollection")
        XCTAssertEqual(catalog.abstract.first?.text, "Synthetic tutorial bundle used by docc2context tests.")
        XCTAssertEqual(catalog.topics.count, 1)
        XCTAssertEqual(catalog.topics.first?.title, "Getting Started")
        XCTAssertEqual(catalog.topics.first?.identifiers,
                       ["tutorialcatalog/tutorials/getting-started"])
    }

    func test_symbolGraphReferencesLoadFromArticleReferenceBundle() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        let parser = DoccMetadataParser()

        let references = try parser.loadSymbolGraphReferences(from: fixturesURL)

        XCTAssertEqual(references.count, 1)
        XCTAssertEqual(references.first?.identifier, "docc2contextcommand")
        XCTAssertEqual(references.first?.title, "Docc2contextCommand")
        XCTAssertEqual(references.first?.moduleName, "Docc2contextCore")
    }
}
