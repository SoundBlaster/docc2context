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

    func testRenderArchiveArticleRenersReferencesWithUrlAsLinks() throws {
        let json = """
        {
          "kind": "article",
          "identifier": { "url": "doc://test/documentation/Test/Overview" },
          "metadata": { "title": "Overview" },
          "abstract": [{ "type": "text", "text": "Reference guide." }],
          "references": {
            "doc://test/documentation/Test/SomeClass": {
              "identifier": "doc://test/documentation/Test/SomeClass",
              "kind": "symbol",
              "title": "SomeClass",
              "url": "/documentation/test/someclass"
            }
          },
          "primaryContentSections": [
            {
              "content": [
                { "type": "heading", "text": "See Also", "level": 2 },
                {
                  "type": "paragraph",
                  "inlineContent": [
                    { "type": "text", "text": "Check out " },
                    { "type": "reference", "identifier": "doc://test/documentation/Test/SomeClass", "isActive": true },
                    { "type": "text", "text": " for details." }
                  ]
                }
              ]
            }
          ],
          "topicSections": []
        }
        """

        let article = try JSONDecoder().decode(DoccArticle.self, from: Data(json.utf8))
        XCTAssertEqual(article.title, "Overview")

        let seeAlso = article.sections[0].content.joined(separator: "\n")
        // Reference with URL should render as a Markdown link
        XCTAssertTrue(seeAlso.contains("[SomeClass](/documentation/test/someclass)"),
                      "Expected reference with URL to render as Markdown link, but got: \(seeAlso)")
    }

    func testRenderArchiveArticleRendersAsidesAsBlockquotes() throws {
        let json = """
        {
          "kind": "article",
          "identifier": { "url": "doc://test/documentation/Test/ThreadSafety" },
          "metadata": { "title": "Thread Safety Guide" },
          "abstract": [{ "type": "text", "text": "Understanding concurrency." }],
          "references": {},
          "primaryContentSections": [
            {
              "content": [
                { "type": "heading", "text": "Important", "level": 2 },
                {
                  "type": "aside",
                  "style": "note",
                  "name": "Note",
                  "content": [
                    {
                      "type": "paragraph",
                      "inlineContent": [
                        { "type": "text", "text": "This API is thread-safe as long as the underlying operation completes atomically." }
                      ]
                    }
                  ]
                }
              ]
            }
          ],
          "topicSections": []
        }
        """

        let article = try JSONDecoder().decode(DoccArticle.self, from: Data(json.utf8))
        XCTAssertEqual(article.title, "Thread Safety Guide")

        let content = article.sections[0].content.joined(separator: "\n")
        // Aside should render as blockquote with style prefix
        XCTAssertTrue(content.contains(">") && content.contains("**Note:**"),
                      "Expected aside to render as blockquote with Note prefix, but got: \(content)")
        XCTAssertTrue(content.contains("thread-safe"),
                      "Expected aside content to be preserved, but got: \(content)")
    }

    func testRenderArchiveArticleRendersImagesAsMarkdownLinks() throws {
        let json = """
        {
          "kind": "article",
          "identifier": { "url": "doc://test/documentation/Test/ImageGuide" },
          "metadata": { "title": "Image Guide" },
          "abstract": [{ "type": "text", "text": "Working with images." }],
          "references": {},
          "primaryContentSections": [
            {
              "content": [
                { "type": "heading", "text": "Screenshots", "level": 2 },
                {
                  "type": "image",
                  "source": "/images/example.png",
                  "altText": "Example application screenshot"
                }
              ]
            }
          ],
          "topicSections": []
        }
        """

        let article = try JSONDecoder().decode(DoccArticle.self, from: Data(json.utf8))
        XCTAssertEqual(article.title, "Image Guide")

        let content = article.sections[0].content.joined(separator: "\n")
        // Image should render as Markdown image syntax
        XCTAssertTrue(content.contains("![Example application screenshot](/images/example.png)"),
                      "Expected image to render as Markdown image link, but got: \(content)")
    }

    func testRenderArchiveArticleRendersTermLists() throws {
        let json = """
        {
          "kind": "article",
          "identifier": { "url": "doc://test/documentation/Test/Glossary" },
          "metadata": { "title": "Glossary" },
          "abstract": [{ "type": "text", "text": "Key terms and definitions." }],
          "references": {},
          "primaryContentSections": [
            {
              "content": [
                { "type": "heading", "text": "Terms", "level": 2 },
                {
                  "type": "termList",
                  "items": [
                    {
                      "content": [
                        {
                          "type": "paragraph",
                          "inlineContent": [
                            { "type": "text", "text": "API: Application Programming Interface - a set of protocols for building software applications." }
                          ]
                        }
                      ]
                    },
                    {
                      "content": [
                        {
                          "type": "paragraph",
                          "inlineContent": [
                            { "type": "text", "text": "HTTP: HyperText Transfer Protocol - the foundation of data communication on the web." }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ],
          "topicSections": []
        }
        """

        let article = try JSONDecoder().decode(DoccArticle.self, from: Data(json.utf8))
        XCTAssertEqual(article.title, "Glossary")

        let content = article.sections[0].content.joined(separator: "\n")
        // Term list should preserve term-definition pairs
        XCTAssertTrue(content.contains("API") && content.contains("Application Programming Interface"),
                      "Expected term list to preserve API definition, but got: \(content)")
        XCTAssertTrue(content.contains("HTTP") && content.contains("HyperText Transfer Protocol"),
                      "Expected term list to preserve HTTP definition, but got: \(content)")
    }
}

