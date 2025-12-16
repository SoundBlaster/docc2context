import XCTest
@testable import Docc2contextCore

final class DoccMetadataParserAdditionalTests: XCTestCase {
    func testErrorDescriptionsAreHumanReadable() {
        let sampleURL = URL(fileURLWithPath: "/tmp/sample.json")

        let cases: [DoccMetadataParserError] = [
            .infoPlistMissing(sampleURL),
            .invalidInfoPlist(sampleURL),
            .missingRequiredField("Identifier"),
            .invalidFieldType(key: "Languages", expected: "[String]"),
            .renderMetadataMissing(sampleURL),
            .invalidRenderMetadata(sampleURL),
            .documentationCatalogMissing(sampleURL),
            .invalidDocumentationCatalog(sampleURL),
            .invalidSymbolGraph(sampleURL),
            .metadataJSONMissing(sampleURL),
            .invalidMetadataJSON(sampleURL),
            .tutorialPageMissing(sampleURL),
            .invalidTutorialPage(sampleURL),
            .articlePageMissing(sampleURL),
            .invalidArticlePage(sampleURL)
        ]

        for error in cases {
            let description = error.errorDescription ?? ""
            XCTAssertFalse(description.isEmpty, "\(error) should expose a description")
        }
    }

    func testTutorialMissingUsesSluggedURL() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let parser = DoccMetadataParser()
            let identifier = "tutorialcatalog/tutorials/custom-tutorial"

            XCTAssertThrowsError(
                try parser.loadTutorialPage(withIdentifier: identifier, from: temporaryDirectory.url)
            ) { error in
                guard case .tutorialPageMissing(let url) = error as? DoccMetadataParserError else {
                    XCTFail("Expected tutorialPageMissing, got \(error)")
                    return
                }
                XCTAssertEqual(url.lastPathComponent, "custom-tutorial.json")
            }
        }
    }

    func testArticleMissingUsesSluggedURL() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let parser = DoccMetadataParser()
            let identifier = "articlereference/documentation/articles/custom-article"

            XCTAssertThrowsError(
                try parser.loadArticlePage(withIdentifier: identifier, from: temporaryDirectory.url)
            ) { error in
                guard case .articlePageMissing(let url) = error as? DoccMetadataParserError else {
                    XCTFail("Expected articlePageMissing, got \(error)")
                    return
                }
                XCTAssertEqual(url.lastPathComponent, "custom-article.json")
            }
        }
    }

    func testArticleCodingRoundTripExercisesNestedTypes() throws {
        let article = DoccArticle(
            identifier: "test/article",
            kind: "article",
            title: "Title",
            abstract: [DoccArticle.AbstractItem(type: "paragraph", text: "Summary")],
            sections: [DoccArticle.Section(title: "Section", content: ["Line 1", "Line 2"])],
            topics: [DoccArticle.TopicSection(title: "Related", identifiers: ["id-1"])],
            references: [DoccArticle.Reference(identifier: "id-1", kind: "symbol", title: "Symbol")])

        let data = try JSONEncoder().encode(article)
        let decoded = try JSONDecoder().decode(DoccArticle.self, from: data)

        XCTAssertEqual(decoded, article)
    }

    func testDocumentationCatalogCodingRoundTripExercisesNestedTypes() throws {
        let catalog = DoccDocumentationCatalog(
            identifier: "test/catalog",
            kind: "documentation",
            title: "Title",
            role: nil,
            abstract: [DoccDocumentationCatalog.AbstractItem(type: "paragraph", text: "Summary")],
            topics: [DoccDocumentationCatalog.TopicSection(title: "Related", identifiers: ["id-1"])])

        let data = try JSONEncoder().encode(catalog)
        let decoded = try JSONDecoder().decode(DoccDocumentationCatalog.self, from: data)

        XCTAssertEqual(decoded, catalog)
    }

    func testDocumentationCatalogInvalidJSONThrowsHelpfulError() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let dataDir = temporaryDirectory.url
                .appendingPathComponent("data", isDirectory: true)
                .appendingPathComponent("documentation", isDirectory: true)
            try FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
            let badURL = dataDir.appendingPathComponent("badroot.json")
            try Data("not json".utf8).write(to: badURL)

            let parser = DoccMetadataParser()
            XCTAssertThrowsError(try parser.loadDocumentationCatalog(from: temporaryDirectory.url, technologyRoot: "badroot")) { error in
                XCTAssertEqual(error as? DoccMetadataParserError, .invalidDocumentationCatalog(badURL))
            }
        }
    }

    func testBundleDataMetadataMissingThrowsHelpfulError() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let parser = DoccMetadataParser()
            XCTAssertThrowsError(try parser.loadBundleDataMetadata(from: temporaryDirectory.url)) { error in
                let expectedURL = temporaryDirectory.url
                    .appendingPathComponent("data", isDirectory: true)
                    .appendingPathComponent("metadata", isDirectory: true)
                    .appendingPathComponent("metadata.json", isDirectory: false)
                XCTAssertEqual(error as? DoccMetadataParserError, .metadataJSONMissing(expectedURL))
            }
        }
    }
}
