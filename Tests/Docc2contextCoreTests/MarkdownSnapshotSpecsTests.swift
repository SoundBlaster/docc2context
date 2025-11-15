import XCTest

@testable import Docc2contextCore

final class MarkdownSnapshotSpecsTests: XCTestCase {
    func test_tutorialOverviewMatchesSnapshot() throws {
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
        let model = try builder.makeBundleModel(
            bundleMetadata: bundleMetadata,
            renderMetadata: renderMetadata,
            documentationCatalog: documentationCatalog,
            bundleDataMetadata: bundleDataMetadata,
            symbolReferences: symbolReferences)

        guard let volume = model.tutorialVolumes.first else {
            XCTFail("Tutorial catalog fixture must include at least one tutorial volume")
            return
        }

        let renderer = DoccMarkdownRenderer()
        let markdown = renderer.renderTutorialVolumeOverview(
            catalog: model.documentationCatalog,
            volume: volume)

        try MarkdownSnapshot.assertSnapshot(
            self,
            matching: markdown,
            named: #function,
            record: SnapshotRecording.isEnabled)
    }
}
