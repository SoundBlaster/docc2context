import XCTest
@testable import Docc2contextCore

final class SwiftDocCRenderArchiveContentRenderingTests: XCTestCase {
    func testSymbolPageRendersTablesFromPrimaryContentSections() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            try Data(#"{"bundleID":"com.example.test","bundleDisplayName":"Test"}"#.utf8)
                .write(to: temp.url.appendingPathComponent("metadata.json", isDirectory: false))

            let documentationDir = temp.url
                .appendingPathComponent("data", isDirectory: true)
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("test", isDirectory: true)
            try FileManager.default.createDirectory(at: documentationDir, withIntermediateDirectories: true)

            let symbolURL = documentationDir.appendingPathComponent("platformcontextproviders.json", isDirectory: false)
            let node = """
            {
              "kind": "symbol",
              "identifier": { "url": "doc://test/documentation/Test/PlatformContextProviders" },
              "metadata": {
                "title": "PlatformContextProviders",
                "roleHeading": "Structure",
                "symbolKind": "struct",
                "role": "symbol",
                "modules": [{ "name": "Test" }]
              },
              "primaryContentSections": [
                {
                  "kind": "content",
                  "content": [
                    {
                      "type": "table",
                      "header": "row",
                      "rows": [
                        [
                          [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "Platform" } ] } ],
                          [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "Battery" } ] } ]
                        ],
                        [
                          [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "iOS" } ] } ],
                          [ { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "Yes" } ] } ]
                        ]
                      ]
                    }
                  ]
                }
              ]
            }
            """
            try Data(node.utf8).write(to: symbolURL)

            let parser = DoccMetadataParser()
            let pages = try parser.loadSwiftDocCRenderArchiveSymbolPages(from: temp.url)
            let page = try XCTUnwrap(pages["doc://test/documentation/Test/PlatformContextProviders"])

            let discussion = page.discussion.joined(separator: "\n")
            XCTAssertTrue(discussion.contains("| Platform | Battery |"))
            XCTAssertTrue(discussion.contains("| --- | --- |"))
            XCTAssertTrue(discussion.contains("| iOS | Yes |"))
        }
    }

    func testSymbolPageRendersInlineReferencesAsLinksWhenPossible() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            try Data(#"{"bundleID":"com.example.test","bundleDisplayName":"Test"}"#.utf8)
                .write(to: temp.url.appendingPathComponent("metadata.json", isDirectory: false))

            let documentationDir = temp.url
                .appendingPathComponent("data", isDirectory: true)
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("test", isDirectory: true)
            try FileManager.default.createDirectory(at: documentationDir, withIntermediateDirectories: true)

            let symbolURL = documentationDir.appendingPathComponent("decides.json", isDirectory: false)
            let node = """
            {
              "kind": "symbol",
              "identifier": { "url": "doc://test/documentation/Test/Decides" },
              "metadata": {
                "title": "Decides",
                "roleHeading": "Structure",
                "symbolKind": "struct",
                "role": "symbol",
                "modules": [{ "name": "Test" }]
              },
              "references": {
                "doc://test/documentation/Test/ContextUpdatesProviding": {
                  "identifier": "doc://test/documentation/Test/ContextUpdatesProviding",
                  "kind": "symbol",
                  "title": "ContextUpdatesProviding",
                  "url": "/documentation/test/contextupdatesproviding"
                }
              },
              "primaryContentSections": [
                {
                  "kind": "content",
                  "content": [
                    {
                      "type": "paragraph",
                      "inlineContent": [
                        { "type": "text", "text": "See " },
                        { "type": "reference", "identifier": "doc://test/documentation/Test/ContextUpdatesProviding", "isActive": true }
                      ]
                    }
                  ]
                }
              ]
            }
            """
            try Data(node.utf8).write(to: symbolURL)

            let parser = DoccMetadataParser()
            let pages = try parser.loadSwiftDocCRenderArchiveSymbolPages(from: temp.url)
            let page = try XCTUnwrap(pages["doc://test/documentation/Test/Decides"])

            let discussion = page.discussion.joined(separator: "\n")
            XCTAssertTrue(discussion.contains("See [ContextUpdatesProviding](/documentation/test/contextupdatesproviding)"))
        }
    }
}

