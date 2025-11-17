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

    func test_tutorialPageLoadsStepsAndAssessments() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "TutorialCatalog.doccarchive")
        let parser = DoccMetadataParser()

        let tutorial = try parser.loadTutorialPage(
            withIdentifier: "tutorialcatalog/tutorials/getting-started",
            from: fixturesURL)

        XCTAssertEqual(tutorial.identifier, "tutorialcatalog/tutorials/getting-started")
        XCTAssertEqual(tutorial.title, "Build the First Page")
        XCTAssertEqual(
            tutorial.introduction,
            "Create a simple documentation page that links out to tutorials and symbols.")
        XCTAssertEqual(tutorial.steps.count, 2)
        XCTAssertEqual(tutorial.steps.first?.title, "Scaffold a DocC bundle")
        XCTAssertEqual(
            tutorial.steps.first?.content,
            [
                "Use swift-docc to generate initial metadata.",
                "Confirm Info.plist values before shipping.",
            ])
        XCTAssertEqual(tutorial.assessments.count, 1)
        XCTAssertEqual(tutorial.assessments.first?.title, "Knowledge Check")
        XCTAssertEqual(tutorial.assessments.first?.items.count, 1)
        XCTAssertEqual(
            tutorial.assessments.first?.items.first?.choices,
            [
                "Scripts/validate_fixtures_manifest.py",
                "swift run docc2context --inspect",
                "xcodebuild docc",
            ])
        XCTAssertEqual(tutorial.assessments.first?.items.first?.answer, 0)
    }

    func test_articlePageLoadsSectionsAndReferences() throws {
        let fixturesURL = FixtureLoader.urlForBundle(named: "ArticleReference.doccarchive")
        let parser = DoccMetadataParser()

        let article = try parser.loadArticlePage(
            withIdentifier: "articlereference/documentation/articles/api-walkthrough",
            from: fixturesURL)

        XCTAssertEqual(article.identifier, "articlereference/documentation/articles/api-walkthrough")
        XCTAssertEqual(article.kind, "article")
        XCTAssertEqual(article.title, "API Walkthrough")
        XCTAssertEqual(article.sections.count, 2)
        XCTAssertEqual(article.sections.first?.title, "Inspect Inputs")
        XCTAssertEqual(
            article.sections.first?.content,
            [
                "Resolve whether the path is a directory or .doccarchive.",
                "Emit structured errors when data is missing.",
            ])
        XCTAssertEqual(article.references.count, 1)
        XCTAssertEqual(article.references.first?.title, "Docc2contextCommand")
        XCTAssertEqual(article.references.first?.kind, "symbol")
        XCTAssertEqual(
            article.references.first?.identifier,
            "articlereference/symbols/Docc2contextCommand")
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

    func test_symbolGraphReferencesSortByModuleWhenIdentifiersMatch() throws {
        let temporaryBundle = try makeTemporaryDoccArchiveDirectory(named: "SymbolGraphSorting")
        defer { try? FileManager.default.removeItem(at: temporaryBundle) }

        let symbolGraphsDirectory = temporaryBundle
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("symbol-graphs", isDirectory: true)
        try FileManager.default.createDirectory(at: symbolGraphsDirectory, withIntermediateDirectories: true)

        let moduleAURL = symbolGraphsDirectory.appendingPathComponent("ModuleA.symbols.json")
        try writeSymbolGraph(
            moduleName: "ModuleA",
            symbols: [["identifier": "shared", "names": ["title": "Shared"]]],
            to: moduleAURL)

        let moduleBURL = symbolGraphsDirectory.appendingPathComponent("ModuleB.symbols.json")
        try writeSymbolGraph(
            moduleName: "ModuleB",
            symbols: [
                ["identifier": "shared", "names": ["title": "Shared"]],
                ["identifier": "", "names": ["title": ""]]
            ],
            to: moduleBURL)

        let parser = DoccMetadataParser()
        let references = try parser.loadSymbolGraphReferences(from: temporaryBundle)

        XCTAssertEqual(references.map(\.moduleName), ["ModuleA", "ModuleB"])
        XCTAssertTrue(references.allSatisfy { $0.identifier == "shared" })
    }

    func test_symbolGraphReferencesThrowOnInvalidJSON() throws {
        let temporaryBundle = try makeTemporaryDoccArchiveDirectory(named: "SymbolGraphInvalidJSON")
        defer { try? FileManager.default.removeItem(at: temporaryBundle) }

        let symbolGraphsDirectory = temporaryBundle
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("symbol-graphs", isDirectory: true)
        try FileManager.default.createDirectory(at: symbolGraphsDirectory, withIntermediateDirectories: true)

        let invalidURL = symbolGraphsDirectory.appendingPathComponent("Invalid.symbols.json")
        try Data("not-json".utf8).write(to: invalidURL)

        let parser = DoccMetadataParser()
        XCTAssertThrowsError(try parser.loadSymbolGraphReferences(from: temporaryBundle)) { error in
            guard case let .invalidSymbolGraph(actualURL) = error as? DoccMetadataParserError else {
                XCTFail("Expected invalidSymbolGraph error, got \(String(describing: error))")
                return
            }
            XCTAssertEqual(
                actualURL.standardizedFileURL,
                invalidURL.standardizedFileURL,
                "Symbol graph error should report the invalid file path")
        }
    }

    func test_renderMetadataMissingThrowsHelpfulError() throws {
        let temporaryBundle = try makeTemporaryDoccArchiveDirectory(named: "RenderMetadataMissing")
        defer { try? FileManager.default.removeItem(at: temporaryBundle) }
        let parser = DoccMetadataParser()
        let expectedURL = temporaryBundle
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("metadata", isDirectory: true)
            .appendingPathComponent("metadata.json", isDirectory: false)

        XCTAssertThrowsError(try parser.loadRenderMetadata(from: temporaryBundle)) { error in
            XCTAssertEqual(error as? DoccMetadataParserError, .renderMetadataMissing(expectedURL))
        }
    }

    func test_infoPlistRejectsInvalidLanguageContainer() throws {
        let temporaryBundle = try makeTemporaryDoccArchiveDirectory(named: "LanguagesNotArray")
        defer { try? FileManager.default.removeItem(at: temporaryBundle) }

        let infoPlist: [String: Any] = [
            "Identifier": "com.docc2context.temp",
            "CFBundleName": "Temporary Bundle",
            "TechnologyRoot": "temporary",
            "Languages": "en"
        ]

        try writeInfoPlist(infoPlist, to: temporaryBundle)

        let parser = DoccMetadataParser()
        XCTAssertThrowsError(try parser.loadInfoPlist(from: temporaryBundle)) { error in
            XCTAssertEqual(error as? DoccMetadataParserError, .invalidFieldType(key: "Languages", expected: "[String]"))
        }
    }

    func test_infoPlistRejectsEmptyLanguageEntries() throws {
        let temporaryBundle = try makeTemporaryDoccArchiveDirectory(named: "EmptyLanguageEntry")
        defer { try? FileManager.default.removeItem(at: temporaryBundle) }

        let infoPlist: [String: Any] = [
            "Identifier": "com.docc2context.temp",
            "CFBundleName": "Temporary Bundle",
            "TechnologyRoot": "temporary",
            "Languages": ["en", "  "]
        ]

        try writeInfoPlist(infoPlist, to: temporaryBundle)

        let parser = DoccMetadataParser()
        XCTAssertThrowsError(try parser.loadInfoPlist(from: temporaryBundle)) { error in
            XCTAssertEqual(
                error as? DoccMetadataParserError,
                .invalidFieldType(key: "Languages", expected: "non-empty strings"))
        }
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

    private func writeSymbolGraph(
        moduleName: String,
        symbols: [[String: Any]],
        to fileURL: URL
    ) throws {
        let payload: [String: Any] = [
            "module": ["name": moduleName],
            "symbols": symbols
        ]
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        try data.write(to: fileURL)
    }
}
