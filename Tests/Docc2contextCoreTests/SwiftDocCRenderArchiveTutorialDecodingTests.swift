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
}

