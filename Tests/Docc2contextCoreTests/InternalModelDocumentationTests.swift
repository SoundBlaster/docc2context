import XCTest
@testable import Docc2contextCore

final class InternalModelDocumentationTests: XCTestCase {
    func test_readmeDocumentsInternalModelMapping() throws {
        let docsURL = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("DOCS", isDirectory: true)
            .appendingPathComponent("README", isDirectory: true)
            .appendingPathComponent("internals.md", isDirectory: false)
        let readme = try String(contentsOf: docsURL, encoding: .utf8)

        let startToken = "<!-- INTERNAL_MODEL_DOC_START -->"
        let endToken = "<!-- INTERNAL_MODEL_DOC_END -->"

        guard let startRange = readme.range(of: startToken) else {
            XCTFail("Docs missing \(startToken) marker")
            return
        }
        guard let endRange = readme.range(of: endToken) else {
            XCTFail("Docs missing \(endToken) marker")
            return
        }
        let section = readme[startRange.upperBound..<endRange.lowerBound]

        let requiredPhrases = [
            "DoccBundleModel",
            "DoccDocumentationCatalog",
            "DoccTutorialVolume",
            "DoccTutorialChapter",
            "DoccSymbolReference",
            "tutorial volumes preserve",
            "chapters maintain the DocC topic order"
        ]

        for phrase in requiredPhrases {
            XCTAssertTrue(section.localizedCaseInsensitiveContains(phrase), "Missing documentation phrase: \(phrase)")
        }
    }
}
