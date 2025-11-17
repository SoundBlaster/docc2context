import XCTest

final class DocumentationGuidanceTests: XCTestCase {
    private func loadReadme() throws -> String {
        let readmeURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("README.md")
        return try String(contentsOf: readmeURL, encoding: .utf8)
    }

    func test_readmeIncludesFixturesAndReleaseGuidance() throws {
        let readme = try loadReadme()
        XCTAssertTrue(readme.contains("Fixtures/manifest.json"), "README should document the fixture manifest")
        XCTAssertTrue(readme.contains("Scripts/validate_fixtures_manifest.py"), "README should mention the fixture validation script")
        XCTAssertTrue(readme.contains("Scripts/release_gates.sh"), "README should describe running release gates")
        XCTAssertTrue(readme.contains("swift test --enable-code-coverage"), "README should tell contributors how to run coverage-enabled tests")
        XCTAssertTrue(readme.contains("python3 Scripts/enforce_coverage.py"), "README should reference the coverage helper script")
    }

    func test_readmeMentionsTroubleshootingGuidance() throws {
        let readme = try loadReadme()
        XCTAssertTrue(readme.contains("## Troubleshooting & FAQ"), "README should contain a troubleshooting section for contributors")
        XCTAssertTrue(readme.contains("Scripts/lint_markdown.py"), "README should mention the Markdown lint workflow")
    }
}
