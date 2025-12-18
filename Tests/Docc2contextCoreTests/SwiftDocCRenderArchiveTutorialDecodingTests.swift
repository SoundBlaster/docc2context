import XCTest
@testable import Docc2contextCore

final class SwiftDocCRenderArchiveTutorialDecodingTests: XCTestCase {
    func testLoadTutorialPageDecodesRenderArchiveProjectNodes() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            try Data(#"{"bundleID":"com.example.test","bundleDisplayName":"Test"}"#.utf8)
                .write(to: temp.url.appendingPathComponent("metadata.json", isDirectory: false))

            let tutorialsDir = temp.url
                .appendingPathComponent("data", isDirectory: true)
                .appendingPathComponent("tutorials", isDirectory: true)
                .appendingPathComponent("test", isDirectory: true)
            try FileManager.default.createDirectory(at: tutorialsDir, withIntermediateDirectories: true)

            let tutorialURL = tutorialsDir.appendingPathComponent("gettingstarted.json", isDirectory: false)
            let json = """
            {
              "kind": "project",
              "identifier": { "url": "doc://test/tutorials/Test/GettingStarted" },
              "metadata": { "title": "Getting Started", "role": "project" },
              "sections": [
                {
                  "kind": "hero",
                  "title": "Getting Started",
                  "estimatedTimeInMinutes": 30,
                  "content": [
                    { "type": "paragraph", "inlineContent": [ { "type": "text", "text": "Intro paragraph." } ] }
                  ]
                },
                {
                  "kind": "tasks",
                  "tasks": [
                    { "title": "First Task", "anchor": "First-Task", "content": [] },
                    { "title": "Second Task", "anchor": "Second-Task", "content": [] }
                  ]
                }
              ],
              "references": {
                "doc://test/tutorials/Test/GettingStarted#First-Task": {
                  "identifier": "doc://test/tutorials/Test/GettingStarted#First-Task",
                  "title": "First Task",
                  "abstract": [ { "type": "text", "text": "First task abstract." } ]
                }
              }
            }
            """
            try Data(json.utf8).write(to: tutorialURL)

            let parser = DoccMetadataParser()
            let tutorial = try parser.loadTutorialPage(
                withIdentifier: "doc://test/tutorials/Test/GettingStarted",
                from: temp.url
            )

            XCTAssertEqual(tutorial.identifier, "doc://test/tutorials/Test/GettingStarted")
            XCTAssertEqual(tutorial.title, "Getting Started")
            XCTAssertEqual(tutorial.introduction, "Intro paragraph.")
            XCTAssertEqual(tutorial.steps.map(\.title), ["First Task", "Second Task"])
            XCTAssertEqual(tutorial.steps.first?.content.first, "First task abstract.")
        }
    }

    func testRenderArchiveTutorialDecodingRendersInlineVariantsAndMissingReferencesGracefully() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temp in
            try Data(#"{"bundleID":"com.example.test","bundleDisplayName":"Test"}"#.utf8)
                .write(to: temp.url.appendingPathComponent("metadata.json", isDirectory: false))

            let tutorialsDir = temp.url
                .appendingPathComponent("data", isDirectory: true)
                .appendingPathComponent("tutorials", isDirectory: true)
                .appendingPathComponent("test", isDirectory: true)
            try FileManager.default.createDirectory(at: tutorialsDir, withIntermediateDirectories: true)

            let tutorialURL = tutorialsDir.appendingPathComponent("advanced.json", isDirectory: false)
            let json = """
            {
              "kind": "project",
              "identifier": { "url": "doc://test/tutorials/Test/Advanced" },
              "metadata": { "title": "Advanced", "role": "project" },
              "sections": [
                {
                  "kind": "hero",
                  "title": "Advanced",
                  "content": [
                    {
                      "type": "paragraph",
                      "inlineContent": [
                        { "type": "text", "text": "Use " },
                        { "type": "strong", "inlineContent": [ { "type": "text", "text": "strong" } ] },
                        { "type": "text", "text": " and " },
                        { "type": "emphasis", "inlineContent": [ { "type": "text", "text": "emphasis" } ] },
                        { "type": "text", "text": " plus " },
                        { "type": "codeVoice", "code": "code" },
                        { "type": "text", "text": " and refs: " },
                        { "type": "reference", "identifier": "doc://test/tutorials/Test/Advanced#Referenced", "isActive": true }
                      ]
                    }
                  ]
                },
                {
                  "kind": "tasks",
                  "tasks": [
                    { "title": "Has Abstract", "anchor": "Has-Abstract", "content": [] },
                    { "title": "Missing Abstract", "anchor": "Missing-Abstract", "content": [] },
                    { "title": "No Anchor", "content": [] }
                  ]
                }
              ],
              "references": {
                "doc://test/tutorials/Test/Advanced#Referenced": {
                  "identifier": "doc://test/tutorials/Test/Advanced#Referenced",
                  "title": "Referenced"
                },
                "doc://test/tutorials/Test/Advanced#Has-Abstract": {
                  "identifier": "doc://test/tutorials/Test/Advanced#Has-Abstract",
                  "title": "Has Abstract",
                  "abstract": [
                    { "type": "text", "text": "Hello " },
                    { "type": "codeVoice", "code": "World" }
                  ]
                }
              }
            }
            """
            try Data(json.utf8).write(to: tutorialURL)

            let parser = DoccMetadataParser()
            let tutorial = try parser.loadTutorialPage(
                withIdentifier: "doc://test/tutorials/Test/Advanced",
                from: temp.url
            )

            XCTAssertEqual(tutorial.title, "Advanced")
            XCTAssertEqual(
                tutorial.introduction,
                "Use strong and emphasis plus `code` and refs: Referenced"
            )

            XCTAssertEqual(tutorial.steps.map(\.title), ["Has Abstract", "Missing Abstract", "No Anchor"])
            XCTAssertEqual(tutorial.steps[0].content, ["Hello", "`World`"])
            XCTAssertEqual(tutorial.steps[1].content, [])
            XCTAssertEqual(tutorial.steps[2].content, [])
        }
    }

    func testRenderArchiveTutorialDecodingRejectsUnsupportedKind() throws {
        let json = """
        {
          "kind": "tutorial",
          "identifier": { "url": "doc://test/tutorials/Test/NotAProject" },
          "metadata": { "title": "Not A Project", "role": "tutorial" },
          "sections": [],
          "references": {}
        }
        """

        XCTAssertThrowsError(try JSONDecoder().decode(DoccTutorial.self, from: Data(json.utf8)))
    }
}
