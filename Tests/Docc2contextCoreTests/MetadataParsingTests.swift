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
        let catalog = try parser.loadDocumentationCatalog(
            from: fixturesURL,
            technologyRoot: info.technologyRoot)

        XCTAssertEqual(catalog.identifier, "tutorialcatalog")
        XCTAssertEqual(catalog.kind, "technology")
        XCTAssertEqual(catalog.title, "DocC2Context Tutorial Catalog")
        XCTAssertEqual(catalog.role, "tutorialCollection")
        XCTAssertEqual(
            catalog.abstract.first?.text, "Synthetic tutorial bundle used by docc2context tests.")
        XCTAssertEqual(catalog.topics.count, 1)
        XCTAssertEqual(catalog.topics.first?.title, "Getting Started")
        XCTAssertEqual(
            catalog.topics.first?.identifiers,
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

    func test_metadataJSONLoadsBundleGenerationInfo() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let parser = DoccMetadataParser()

        let bundleMetadata = try parser.loadBundleDataMetadata(from: fixturesURL)

        XCTAssertEqual(bundleMetadata.formatVersion, "1.0")
        XCTAssertEqual(bundleMetadata.generator, "docc2context synthetic fixture")
        XCTAssertEqual(bundleMetadata.kind, "tutorial")

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        XCTAssertEqual(bundleMetadata.generatedAt, formatter.date(from: "2025-11-14T00:00:00Z"))
    }

    func test_infoPlistRejectsEmptyOptionalStrings() throws {
        let temporaryBundle = try makeTemporaryDoccArchiveDirectory(named: "EmptyOptionalStrings")
        defer { try? FileManager.default.removeItem(at: temporaryBundle) }

        let infoPlist: [String: Any] = [
            "Identifier": "com.docc2context.temp",
            "CFBundleName": "Temporary Bundle",
            "TechnologyRoot": "temporary",
            "Languages": ["en"],
            "DocCVersion": "   ",
        ]

        try writeInfoPlist(infoPlist, to: temporaryBundle)

        let parser = DoccMetadataParser()

        XCTAssertThrowsError(try parser.loadInfoPlist(from: temporaryBundle)) { error in
            XCTAssertEqual(
                error as? DoccMetadataParserError,
                .invalidFieldType(key: "DocCVersion", expected: "non-empty String"))
        }
    }

    func test_symbolGraphReferencesIgnoreNonSymbolGraphJSONFiles() throws {
        let temporaryBundle = try makeTemporaryDoccArchiveDirectory(named: "SymbolGraphFiltering")
        defer { try? FileManager.default.removeItem(at: temporaryBundle) }

        let symbolGraphsDirectory =
            temporaryBundle
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("symbol-graphs", isDirectory: true)
        try FileManager.default.createDirectory(
            at: symbolGraphsDirectory,
            withIntermediateDirectories: true,
            attributes: nil)

        let validGraphURL = symbolGraphsDirectory.appendingPathComponent("MyModule.symbols.json")
        let validGraph: [String: Any] = [
            "module": ["name": "MyModule"],
            "symbols": [
                [
                    "identifier": "mymodule/example",
                    "names": ["title": "Example"],
                ]
            ],
        ]
        let validData = try JSONSerialization.data(withJSONObject: validGraph, options: [])
        try validData.write(to: validGraphURL)

        let unrelatedJSONURL = symbolGraphsDirectory.appendingPathComponent("notes.json")
        try Data("not symbol graph".utf8).write(to: unrelatedJSONURL)

        let parser = DoccMetadataParser()
        let references = try parser.loadSymbolGraphReferences(from: temporaryBundle)

        XCTAssertEqual(
            references,
            [
                DoccSymbolReference(
                    identifier: "mymodule/example",
                    title: "Example",
                    moduleName: "MyModule")
            ])
    }
}

// MARK: - Helpers

extension MetadataParsingTests {
    private func makeTemporaryDoccArchiveDirectory(named name: String) throws -> URL {
        let baseURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("docc2context-tests", isDirectory: true)
            .appendingPathComponent(name + "-" + UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
        return baseURL
    }

    private func writeInfoPlist(_ plist: [String: Any], to bundleURL: URL) throws {
        let infoURL = bundleURL.appendingPathComponent("Info.plist", isDirectory: false)
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0)
        try data.write(to: infoURL)
    }
}
