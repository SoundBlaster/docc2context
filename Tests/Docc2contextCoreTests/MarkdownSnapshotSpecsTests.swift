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

    func test_tutorialChapterPageMatchesSnapshot() throws {
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

        guard let chapter = volume.chapters.first else {
            XCTFail("Tutorial catalog fixture must include at least one chapter")
            return
        }

        XCTAssertFalse(chapter.pageIdentifiers.isEmpty, "Chapter must reference at least one tutorial page")

        let tutorials = try chapter.pageIdentifiers.map { identifier in
            try parser.loadTutorialPage(withIdentifier: identifier, from: fixturesURL)
        }

        let renderer = DoccMarkdownRenderer()
        let markdown = renderer.renderTutorialChapterPage(
            catalog: model.documentationCatalog,
            volume: volume,
            chapter: chapter,
            tutorials: tutorials)

        try MarkdownSnapshot.assertSnapshot(
            self,
            matching: markdown,
            named: #function,
            record: SnapshotRecording.isEnabled)
    }

    func test_referenceArticlePageMatchesSnapshot() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
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

        let articleIdentifier = "articlereference/documentation/articles/api-walkthrough"
        let article = try parser.loadArticlePage(
            withIdentifier: articleIdentifier,
            from: fixturesURL)

        let renderer = DoccMarkdownRenderer()
        let markdown = renderer.renderReferenceArticle(
            catalog: model.documentationCatalog,
            article: article)

        try MarkdownSnapshot.assertSnapshot(
            self,
            matching: markdown,
            named: #function,
            record: SnapshotRecording.isEnabled)
    }
}
