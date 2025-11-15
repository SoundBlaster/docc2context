import XCTest

@testable import Docc2contextCore

final class DoccInternalModelBuilderTests: XCTestCase {
    func test_buildsTutorialVolumeOrderingFromCatalogFixture() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let parser = DoccMetadataParser()

        let bundleMetadata = try parser.loadInfoPlist(from: fixturesURL)
        let renderMetadata = try parser.loadRenderMetadata(from: fixturesURL)
        let catalog = try parser.loadDocumentationCatalog(
            from: fixturesURL,
            technologyRoot: bundleMetadata.technologyRoot)
        let bundleDataMetadata = try parser.loadBundleDataMetadata(from: fixturesURL)
        let symbolReferences = try parser.loadSymbolGraphReferences(from: fixturesURL)

        let builder = DoccInternalModelBuilder()
        let model = try builder.makeBundleModel(
            bundleMetadata: bundleMetadata,
            renderMetadata: renderMetadata,
            documentationCatalog: catalog,
            bundleDataMetadata: bundleDataMetadata,
            symbolReferences: symbolReferences)

        XCTAssertEqual(model.bundleMetadata.identifier, "com.docc2context.tutorialcatalog")
        XCTAssertEqual(model.renderMetadata.kind, "tutorial")
        XCTAssertEqual(model.bundleDataMetadata.kind, "tutorial")
        XCTAssertEqual(model.tutorialVolumes.map(\.identifier), ["tutorialcatalog"])
        XCTAssertEqual(model.tutorialVolumes.map(\.title), ["DocC2Context Tutorial Catalog"])
        XCTAssertEqual(model.tutorialVolumes.first?.chapters, [
            DoccTutorialChapter(
                title: "Getting Started",
                pageIdentifiers: ["tutorialcatalog/tutorials/getting-started"]),
        ])
        XCTAssertEqual(model.symbolReferences, symbolReferences)
    }
}
