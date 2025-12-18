import XCTest
@testable import Docc2contextCore

final class SwiftDocCRenderArchiveArticleRenderingTests: XCTestCase {
    func testRenderArchiveArticleRendersListsCodeAndTablesIntoSections() throws {
        let json = """
        {
          "kind": "article",
          "identifier": { "url": "doc://test/documentation/Test/PlatformContextProviders" },
          "metadata": { "title": "Platform-Specific Context Providers" },
          "abstract": [{ "type": "text", "text": "Build context-aware applications." }],
          "references": {
            "doc://test/documentation/Test/DeviceContextProvider": {
              "identifier": "doc://test/documentation/Test/DeviceContextProvider",
              "kind": "symbol",
              "title": "DeviceContextProvider"
            }
          },
          "primaryContentSections": [
            {
              "content": [
                { "type": "heading", "text": "Overview", "level": 2 },
                {
                  "type": "paragraph",
                  "inlineContent": [
                    { "type": "text", "text": "Use " },
                    { "type": "reference", "identifier": "doc://test/documentation/Test/DeviceContextProvider", "isActive": true },
                    { "type": "text", "text": " for device state." }
                  ]
                },
                { "type": "heading", "text": "Key Features", "level": 2 },
                {
                  "type": "unorderedList",
                  "items": [
                    { "content": [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "Fast" } ] } ] },
                    { "content": [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "Deterministic" } ] } ] }
                  ]
                },
                { "type": "heading", "text": "Example", "level": 2 },
                { "type": "codeListing", "syntax": "swift", "code": ["let x = 1", "print(x)"] },
                { "type": "heading", "text": "Support Matrix", "level": 2 },
                {
                  "type": "table",
                  "header": "row",
                  "rows": [
                    [
                      [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "Platform" } ] } ],
                      [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "Supported" } ] } ]
                    ],
                    [
                      [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "iOS" } ] } ],
                      [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "Yes" } ] } ]
                    ]
                  ]
                }
              ]
            }
          ],
          "topicSections": []
        }
        """

        let article = try JSONDecoder().decode(DoccArticle.self, from: Data(json.utf8))
        XCTAssertEqual(article.title, "Platform-Specific Context Providers")
        XCTAssertEqual(article.abstract.first?.text, "Build context-aware applications.")

        XCTAssertEqual(article.sections.map(\.title), ["Overview", "Key Features", "Example", "Support Matrix"])

        let overview = article.sections[0].content.joined(separator: "\n")
        XCTAssertTrue(overview.contains("Use DeviceContextProvider for device state."))

        let features = article.sections[1].content.joined(separator: "\n")
        XCTAssertTrue(features.contains("- Fast"))
        XCTAssertTrue(features.contains("- Deterministic"))

        let example = article.sections[2].content.joined(separator: "\n")
        XCTAssertTrue(example.contains("```swift"))
        XCTAssertTrue(example.contains("let x = 1"))

        let table = article.sections[3].content.joined(separator: "\n")
        XCTAssertTrue(table.contains("| Platform | Supported |"))
        XCTAssertTrue(table.contains("| iOS | Yes |"))
    }
}

