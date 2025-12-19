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

    func testRenderSymbolPageWithAvailabilityMetadata() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            try Data(#"{"bundleID":"com.example.test","bundleDisplayName":"Test"}"#.utf8)
                .write(to: temp.url.appendingPathComponent("metadata.json", isDirectory: false))

            let documentationDir = temp.url
                .appendingPathComponent("data", isDirectory: true)
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("test", isDirectory: true)
            try FileManager.default.createDirectory(at: documentationDir, withIntermediateDirectories: true)

            let symbolURL = documentationDir.appendingPathComponent("availablesymbol.json", isDirectory: false)
            let node = """
            {
              "kind": "symbol",
              "identifier": { "url": "doc://test/documentation/Test/AvailableSymbol" },
              "metadata": {
                "title": "AvailableSymbol",
                "roleHeading": "Structure",
                "symbolKind": "struct",
                "role": "symbol",
                "modules": [{ "name": "Test" }],
                "availability": [
                  "Available in iOS 14.0 and later",
                  "Available in macOS 11.0 and later"
                ]
              },
              "primaryContentSections": []
            }
            """
            try Data(node.utf8).write(to: symbolURL)

            let parser = DoccMetadataParser()
            let pages = try parser.loadSwiftDocCRenderArchiveSymbolPages(from: temp.url)
            let page = try XCTUnwrap(pages["doc://test/documentation/Test/AvailableSymbol"])

            // Verify availability metadata is extracted
            XCTAssertNotNil(page.availability)
            XCTAssertEqual(page.availability?.count, 2)
            XCTAssertTrue(page.availability?.contains("Available in iOS 14.0 and later") ?? false)
            XCTAssertTrue(page.availability?.contains("Available in macOS 11.0 and later") ?? false)
        }
    }

    func testRenderSymbolPageWithDeprecationMetadata() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            try Data(#"{"bundleID":"com.example.test","bundleDisplayName":"Test"}"#.utf8)
                .write(to: temp.url.appendingPathComponent("metadata.json", isDirectory: false))

            let documentationDir = temp.url
                .appendingPathComponent("data", isDirectory: true)
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("test", isDirectory: true)
            try FileManager.default.createDirectory(at: documentationDir, withIntermediateDirectories: true)

            let symbolURL = documentationDir.appendingPathComponent("deprecatedsymbol.json", isDirectory: false)
            let node = """
            {
              "kind": "symbol",
              "identifier": { "url": "doc://test/documentation/Test/DeprecatedSymbol" },
              "metadata": {
                "title": "DeprecatedSymbol",
                "roleHeading": "Structure",
                "symbolKind": "struct",
                "role": "symbol",
                "modules": [{ "name": "Test" }],
                "deprecated": true,
                "deprecatedSummary": "Use NewSymbol instead for improved performance"
              },
              "primaryContentSections": []
            }
            """
            try Data(node.utf8).write(to: symbolURL)

            let parser = DoccMetadataParser()
            let pages = try parser.loadSwiftDocCRenderArchiveSymbolPages(from: temp.url)
            let page = try XCTUnwrap(pages["doc://test/documentation/Test/DeprecatedSymbol"])

            // Verify deprecation metadata is extracted
            XCTAssertTrue(page.isDeprecated)
            XCTAssertEqual(page.deprecatedSummary, "Use NewSymbol instead for improved performance")
        }
    }

    func testRenderProtocolSymbolPageWithDefaultImplementations() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            try Data(#"{"bundleID":"com.example.test","bundleDisplayName":"Test"}"#.utf8)
                .write(to: temp.url.appendingPathComponent("metadata.json", isDirectory: false))

            let documentationDir = temp.url
                .appendingPathComponent("data", isDirectory: true)
                .appendingPathComponent("documentation", isDirectory: true)
                .appendingPathComponent("test", isDirectory: true)
            try FileManager.default.createDirectory(at: documentationDir, withIntermediateDirectories: true)

            let symbolURL = documentationDir.appendingPathComponent("protocolsymbol.json", isDirectory: false)
            let node = """
            {
              "kind": "symbol",
              "identifier": { "url": "doc://test/documentation/Test/ProtocolSymbol" },
              "metadata": {
                "title": "ProtocolSymbol",
                "roleHeading": "Protocol",
                "symbolKind": "protocol",
                "role": "symbol",
                "modules": [{ "name": "Test" }],
                "defaultImplementations": [
                  "doc://test/documentation/Test/ConformingType1",
                  "doc://test/documentation/Test/ConformingType2"
                ]
              },
              "primaryContentSections": [],
              "references": {
                "doc://test/documentation/Test/ConformingType1": {
                  "identifier": "doc://test/documentation/Test/ConformingType1",
                  "kind": "symbol",
                  "title": "ConformingType1",
                  "url": "/documentation/test/conformingtype1"
                },
                "doc://test/documentation/Test/ConformingType2": {
                  "identifier": "doc://test/documentation/Test/ConformingType2",
                  "kind": "symbol",
                  "title": "ConformingType2",
                  "url": "/documentation/test/conformingtype2"
                }
              }
            }
            """
            try Data(node.utf8).write(to: symbolURL)

            let parser = DoccMetadataParser()
            let pages = try parser.loadSwiftDocCRenderArchiveSymbolPages(from: temp.url)
            let page = try XCTUnwrap(pages["doc://test/documentation/Test/ProtocolSymbol"])

            // Verify default implementations metadata is extracted
            XCTAssertNotNil(page.defaultImplementations)
            XCTAssertEqual(page.defaultImplementations?.count, 2)
            XCTAssertTrue(page.defaultImplementations?.contains("doc://test/documentation/Test/ConformingType1") ?? false)
            XCTAssertTrue(page.defaultImplementations?.contains("doc://test/documentation/Test/ConformingType2") ?? false)
        }
    }
}

